import UIKit
import Speech
import AVFoundation
import OpenAI

class ViewControllerAppleSpeech: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {
    
    @IBOutlet weak var transcribeButton: UIButton!
    @IBOutlet weak var transcriptionLabel: UILabel!
    @IBOutlet weak var transcriptionLLM: UILabel!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    private let openAI = OpenAI(apiToken: "api-key")


    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpeechRecognizer()
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.transcribeButton.isEnabled = true
                case .denied:
                    self.transcribeButton.isEnabled = false
                    self.transcriptionLabel.text = "Speech recognition access denied"
                case .restricted:
                    self.transcribeButton.isEnabled = false
                    self.transcriptionLabel.text = "Speech recognition restricted"
                case .notDetermined:
                    self.transcribeButton.isEnabled = false
                    self.transcriptionLabel.text = "Speech recognition not authorized"
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
    }
    
    @IBAction func transcribeButtonTapped(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            transcribeButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            transcribeButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    
    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.transcriptionLabel.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                // Stop recording first
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.transcribeButton.setTitle("Start Recording", for: .normal)
                
                if error == nil {
                    // Process with OpenAI
                    Task {
                        do {
                            let transcribedText = self.transcriptionLabel.text ?? ""
                            print("Sending to OpenAI: \(transcribedText)")
                            
                            let message = ChatQuery.ChatCompletionMessageParam(role: .user, content: transcribedText)!
                            let query = ChatQuery(
                                messages: [message],
                                model: .init("model-key"),
                                maxTokens: 1000,
                                temperature: 0.7
                            )
                            
                            let result = try await self.openAI.chats(query: query)
                            
                            if case let .string(responseText) = result.choices.first?.message.content {
                                print("Got response from OpenAI: \(responseText)")
                                DispatchQueue.main.async {
                                    self.transcriptionLLM.text = responseText
                                    
                                    // Reset audio session for playback
                                    do {
                                        let audioSession = AVAudioSession.sharedInstance()
                                        try audioSession.setCategory(.playback, mode: .spokenAudio)
                                        try audioSession.setActive(true)
                                        print("Audio session reset for playback")
                                        
                                        let utterance = AVSpeechUtterance(string: responseText)
                                        utterance.rate = 0.5
                                        utterance.volume = 1.0
                                        self.synthesizer.speak(utterance)
                                    } catch {
                                        print("Failed to reset audio session: \(error)")
                                    }
                                }
                                
                                /*
                                self.transcriptionLLM.text = responseText
                                let utterance = AVSpeechUtterance(string: responseText)
                                utterance.rate = 0.5
                                self.synthesizer.speak(utterance)
                                 */
                            } else {
                                print("No response content from OpenAI")
                                let utterance = AVSpeechUtterance(string: "Sorry, I couldn't understand the response")
                                utterance.rate = 0.5
                                self.synthesizer.speak(utterance)
                            }
                        } catch {
                            print("OpenAI Error: \(error)")
                            let utterance = AVSpeechUtterance(string: "Sorry, there was an error processing your request")
                            utterance.rate = 0.5
                            self.synthesizer.speak(utterance)
                        }
                    }
                }

                // Non OpenAI
                /*
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.transcribeButton.setTitle("Start Recording", for: .normal)
                
                if error == nil {
                    // Speak success message
                    let utterance = AVSpeechUtterance(string: "Transcription successful")
                    utterance.rate = 0.5
                    self.synthesizer.speak(utterance)
                } */
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
}
