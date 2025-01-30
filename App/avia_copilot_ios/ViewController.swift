//
//  ViewController.swift
//  avia_copilot_ios
//
//  Created by Rana Taki on 1/27/25.
//

import UIKit
import AVFoundation
import Foundation

// Assuming the response is an array of choices, each containing a text string
struct SpeechToTextResponse: Codable {
    struct Choice: Codable {
        let text: String
    }
    let choices: [Choice]
}


class ViewController: UIViewController, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    var audioSession = AVAudioSession.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioRecording()
        // Do any additional setup after loading the view.
    }
    
    // BACKEND -- Audio Recording setup
    func setupAudioRecording() {
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
        } catch {
            print("Failed to set up audio recorder:", error)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // UI ACTIONS
    @IBAction func recordTapped(_ sender: UIButton) {
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            sender.setTitle("Start recording", for: .normal)
            // sending audio to API
            transcribeAudio()
        } else {
            audioRecorder?.record()
            sender.setTitle("Stop Recording", for: .normal)
        }
    }
    
    func transcribeAudio() {
        let audioUrl = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        guard let url = URL(string: "https://api.openai.com/v1/audio/transcriptions") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer api-key", forHTTPHeaderField: "Authorization")

        // Declare and define the boundary here
        let boundary = "Boundary-\(UUID().uuidString)"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = createBody(boundary: boundary, data: try! Data(contentsOf: audioUrl), mimeType: "audio/m4a", filename: "recording.m4a")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error sending request to OpenAI:", error ?? "Unknown error")
                return
            }
            
            // Check and print the HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code:", httpResponse.statusCode)
            }
            
            guard let transcription = try? JSONDecoder().decode(SpeechToTextResponse.self, from: data) else {
                print("Failed to decode transcription response")
                return
            }
            DispatchQueue.main.async {
                let transcribedText = transcription.choices.first?.text ?? "No text recognized"
                self.speakText(transcribedText)
                //self.sendTextToAWSLlm(text: transcription.choices.first?.text ?? "")
            }
        }.resume()
    }

    
    func sendTextToAWSLlm(text: String) {
        guard let url = URL(string: "https://your-aws-api.com/process") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["text": text])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error sending request to AWS:", error ?? "Unknown error")
                return
            }
            guard let responseText = String(data: data, encoding: .utf8) else {
                print("Failed to decode AWS response")
                return
            }
            DispatchQueue.main.async {
                self.speakText(responseText)
            }
        }.resume()
    }

    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }

    
    // Creating HTTP Body
    func createBody(boundary: String, data: Data, mimeType: String, filename: String) -> Data {
        var body = Data()

        // Append the boundary
        body.append("--\(boundary)\r\n".data(using: .utf8)!)

        // Append the form data name and filename
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)

        // Append the MIME type
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)

        // Append the actual data
        body.append(data)

        // Append the closing boundary
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}

