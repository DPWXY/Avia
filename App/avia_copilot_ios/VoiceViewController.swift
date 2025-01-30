import UIKit
import AVFoundation
import Speech

class VoiceViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private let openAIKey = "api-key"
    private let awsEndpoint = "your-aws-endpoint"
    private let awsRegion = "your-aws-region"
    private let awsAccessKey = "your-aws-access-key"
    private let awsSecretKey = "your-aws-secret-key"
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if isRecording {
            stopRecordingAndProcess()
            sender.setTitle("Start Recording", for: .normal)
            sender.backgroundColor = .systemBlue
        } else {
            startRecording()
            sender.setTitle("Stop Recording", for: .normal)
            sender.backgroundColor = .systemRed
        }
        isRecording.toggle()
    }
    
    
    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            print("Recording failed: \(error)")
        }
    }
    
    private func stopRecordingAndProcess() {
        audioRecorder?.stop()
        guard let audioFileURL = audioRecorder?.url else { return }
        
        // Convert audio to text using OpenAI
        convertSpeechToText(audioFileURL: audioFileURL) { [weak self] result in
            switch result {
            case .success(let text):
                print("Transcribed text: \(text)")
                self?.queryAwsLLM(text: text) { llmResult in
                    switch llmResult {
                    case .success(let response):
                        print("LLM response: \(response)")
                        self?.convertTextToSpeech(text: response) { speechResult in
                            switch speechResult {
                            case .success(let audioData):
                                self?.playAudioData(audioData)
                            case .failure(let error):
                                print("Text to speech failed: \(error)")
                            }
                        }
                    case .failure(let error):
                        print("LLM query failed: \(error)")
                    }
                }
            case .failure(let error):
                print("Speech to text failed: \(error)")
            }
        }
    }
    
    private func convertSpeechToText(audioFileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        data.append(try! Data(contentsOf: audioFileURL))
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        data.append("whisper-1\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let text = json?["text"] as? String {
                    completion(.success(text))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func queryAwsLLM(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Configure AWS credentials and create a signed request
        // This is a simplified version - you'll need to implement proper AWS request signing
        let url = URL(string: awsEndpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ["inputs": text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let generatedText = json?["generated_text"] as? String {
                    completion(.success(generatedText))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func convertTextToSpeech(text: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "model": "tts-1",
            "voice": "alloy",
            "input": text
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let audioData = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No audio data received"])))
                return
            }
            
            completion(.success(audioData))
        }.resume()
    }
    
    private func playAudioData(_ audioData: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
