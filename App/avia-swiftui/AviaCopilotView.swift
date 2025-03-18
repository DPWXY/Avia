import SwiftUI
import Speech
import AVFoundation
import OpenAI

class ChatViewModel: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let synthesizer = AVSpeechSynthesizer()
    private let openAI: OpenAI
    
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isRecording = false
    @Published var recordingText = ""
    @Published var isSpeaking = false
    
    override init() {
        let configuration = OpenAI.Configuration(token: "your_api_key", timeoutInterval: 60.0)
        openAI = OpenAI(configuration: configuration)
        super.init()
        synthesizer.delegate = self
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    break
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition authorization denied")
                @unknown default:
                    break
                }
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if !granted {
                    print("Microphone permission denied")
                }
            }
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            if isSpeaking {
                stopSpeaking()
            }
            startRecording()
        }
        isRecording.toggle()
    }
    
    private func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognition not available")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                DispatchQueue.main.async {
                    self.recordingText = result.bestTranscription.formattedString
                }
            }
            if let error = error {
                print("Speech recognition error: \(error)")
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        if !recordingText.isEmpty {
            sendMessage(recordingText)
            recordingText = ""
        }
    }
    
    func sendMessage(_ content: String, sender: MessageSender = .user) {
        // Add user message
        let message = ChatMessage(content: content, sender: sender, timestamp: Date())
        messages.append(message)
        
        // Call OpenAI API
        Task {
            do {
                let query = ChatQuery(
                    messages: [.init(role: .user, content: content)!],
                    model: "ft:gpt-4o-2024-08-06:personal::BA4QTgnH"
                )
                
                let result = try await openAI.chats(query: query)
                
                if let responseContent = result.choices.first?.message.content,
                   case .string(let responseText) = responseContent {
                    // Update UI on main thread
                    await MainActor.run {
                        let assistantMessage = ChatMessage(content: responseText,
                                                           sender: .assistant,
                                                           timestamp: Date())
                        messages.append(assistantMessage)
                        print(result.model)
                        speakResponse(responseText)
                    }
                }
            } catch {
                print("OpenAI API error: \(error)")
            }
        }
    }
    
    private func speakResponse(_ text: String) {
        // Stop any ongoing speech before starting new one
        stopSpeaking()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
        isSpeaking = true
    }
}

extension ChatViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }
}

struct AviaCopilotView: View {
    @Binding var selectedTab: Int
    @FocusState private var isInputFocused: Bool
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    selectedTab = 0  // Go back to feed (home tab)
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Avia Copilot")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Placeholder to maintain centered title
                Color.clear
                    .frame(width: 24, height: 24)
            }
            .padding()
            .background(Color(red: 0.051, green: 0.043, blue: 0.267))
            
            // Body
            VStack(spacing: 0) {
                // Microphone Button with Status
                VStack {
                    // Microphone status text (helpful for debugging)
                    if viewModel.isRecording {
                        Text(viewModel.recordingText.isEmpty ? "Listening..." : viewModel.recordingText)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        viewModel.toggleRecording()
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.051, green: 0.043, blue: 0.267),
                                            Color(red: 0.1, green: 0.15, blue: 0.35)
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            // Outer glow when recording
                            if viewModel.isRecording {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [
                                                Color.blue.opacity(0.3),
                                                Color.blue.opacity(0)
                                            ]),
                                            center: .center,
                                            startRadius: 40,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 160, height: 160)
                                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: viewModel.isRecording)
                            }
                            
                            Image(systemName: "mic.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .scaleEffect(viewModel.isRecording ? 1.2 : 1.0)
                        }
                        .animation(.spring(response: 0.3), value: viewModel.isRecording)
                    }
                }
                .frame(height: 200)
                
                // Chat Messages
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding(.vertical)
                }
            }
            
            // Footer
            HStack(spacing: 12) {
                TextField("Write your message", text: $viewModel.inputText)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .tint(.white)
                    .submitLabel(.send)
                    .focused($isInputFocused)
                    .onSubmit {
                        if !viewModel.inputText.isEmpty {
                            viewModel.sendMessage(viewModel.inputText)
                            viewModel.inputText = ""
                        }
                    }
                
                Button(action: {
                    guard !viewModel.inputText.isEmpty else { return }
                    viewModel.sendMessage(viewModel.inputText)
                    viewModel.inputText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color(red: 0.051, green: 0.043, blue: 0.267))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color(red: 0.051, green: 0.043, blue: 0.267))
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.443, green: 0.816, blue: 0.816),
                    Color(red: 0.2, green: 0.4, blue: 0.6),
                    Color(red: 0.051, green: 0.043, blue: 0.267)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            // Ensure permissions are requested when view appears
            // This is important for TestFlight as permissions might not persist
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // This will re-trigger permission requests if needed
                let _ = viewModel
            }
        }
    }
}

#Preview {
    AviaCopilotView(selectedTab: .constant(2))
        .preferredColorScheme(.dark)
}
