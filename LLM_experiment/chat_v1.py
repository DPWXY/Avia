import os
import openai
import pyaudio
import wave
import pygame
import time
import argparse

# Set up the openai api
openai.api_key = os.getenv("OPENAI_API_KEY")
if not openai.api_key:
    openai.api_key = "your_openai_api_key"

# Audio recording settings
CHUNK = 1024            # Number of frames per buffer
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 44100
RECORD_SECONDS = 10      # Duration to record
OUTPUT_WAV = "data/input_audio.wav"

def record_audio(seconds=RECORD_SECONDS, output_file=OUTPUT_WAV):
    """Record audio from the default microphone for a specified duration."""
    p = pyaudio.PyAudio()
    stream = p.open(format=FORMAT,
                    channels=CHANNELS,
                    rate=RATE,
                    input=True,
                    frames_per_buffer=CHUNK)

    print(f"Recording audio for {seconds} seconds...")
    frames = []

    for _ in range(int(RATE / CHUNK * seconds)):
        data = stream.read(CHUNK)
        frames.append(data)

    # Stop and close the stream
    stream.stop_stream()
    stream.close()
    p.terminate()

    # Save the recorded data as a WAV file
    wf = wave.open(output_file, 'wb')
    wf.setnchannels(CHANNELS)
    wf.setsampwidth(p.get_sample_size(FORMAT))
    wf.setframerate(RATE)
    wf.writeframes(b''.join(frames))
    wf.close()

    print(f"Audio recorded and saved to {output_file}")

# Speech to text
def transcribe_audio(file_path):
    print("Transcribing audio via OpenAI Whisper API...")
    with open(file_path, "rb") as audio_file:
        transcript = openai.audio.transcriptions.create(
            model="whisper-1", 
            file=audio_file
        )
    text = transcript.text
    print("Transcription: ", text)
    return text

def get_prompt(prompt):
    new_prompt = f"""Question: Engine Fire on Ground
Steps: Continue cranking the magnetos to attempt to start the engine. 
If the engine starts, increase power to 1800 RPM for a few minutes, then shut down the engine and inspect for damage. 
If the engine doesn't start: 
Set throttle to full and mixture to idle.
Continue cranking the magnetos.
Shut off the fuel selector.
Turn off the fuel pump, magnetos, standby battery, and master switch.
Obtain a fire extinguisher. Evacuate passengers. Extinguish the fire.

Question: {prompt}
Steps:"""
    return new_prompt

# GPT guidance generation
def chat_with_gpt(prompt):
    print("Sending prompt to OpenAI GPT model...")
    response = openai.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "You are a pilot assitant."},
            {"role": "user", "content": get_prompt(prompt)}
        ],
    )
    reply = response.choices[0].message.content
    print("GPT Response: ", reply)
    return reply

# Text to Speech
def speak_text(text, speech_file_path):
    response = openai.audio.speech.create(
        model="tts-1",
        voice="alloy",
        input=text,
    )
    response.stream_to_file(speech_file_path)

# Play audio
def play_file(speech_file_path):
    print("Playing the generated speech...")
    pygame.mixer.init()
    pygame.mixer.music.load(speech_file_path)
    pygame.mixer.music.play()
    print("Playing... Press Ctrl+C to stop")
    while pygame.mixer.music.get_busy():
        pygame.time.Clock().tick(10)

def main():
    # parser = argparse.ArgumentParser(description="Parser")
    # parser.add_argument('--data_path', type=str, help='Path to dataset')
    
    # args = parser.parse_args()
    OUTPUT_WAV = "data/input_audio.wav"
    OUTPUT_MP3 = "data/output.mp3"

    record_audio()
    user_text = transcribe_audio(OUTPUT_WAV)
    gpt_reply = chat_with_gpt(user_text)
    speak_text(gpt_reply, OUTPUT_MP3)
    play_file(OUTPUT_MP3)

    print("===== Demo Finished =====")

if __name__ == "__main__":
    main()
