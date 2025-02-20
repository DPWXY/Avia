import SwiftUI
import AVFoundation

struct ContentV: View {
    @State private var messageText: String = ""
    @State private var messages: [(text: String, isFromUser: Bool)] = []
    @State private var isRecording = false
    @State private var speechRecognizer = SFSpeechRecognizer()
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(0..<messages.count, id: \.self) { index in
                            MessageBubble(message: messages[index].text,
                                        isFromUser: messages[index].isFromUser)
                        }
                    }
                    .padding(.vertical)
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(messages.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
            
            inputView
        }
        .background(Color(red: 249/255, green: 249/255, blue: 249/255))
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var headerView: some View {
        VStack(spacing: 9) {
            Text("Avia copilot")
                .font(.custom("DMSans-Bold", size: 18))
            Text("You have no notifications at this time thank you")
                .font(.custom("DMSans-Regular", size: 12))
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.black)
        .padding()
        .background(Color.white)
    }
    
    private var inputView: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                TextField("Write your message", text: $messageText)
                    .font(.custom("DMSans-Regular", size: 14))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 2)
                
                Button(action: {
                    isRecording.toggle()
                    // Add speech recognition logic here
                }) {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .foregroundColor(isRecording ? .red : .blue)
                        .font(.system(size: 20))
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 2)
                }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 30))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(red: 249/255, green: 249/255, blue: 249/255))
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        messages.append((messageText, true))
        messageText = ""
        
        // Simulate response (replace with actual chatbot logic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            messages.append(("Thanks for your message!", false))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentV()
    }
}

