import SwiftUI

struct ChatView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    // Simple message model
    struct Message: Identifiable {
        let id = UUID()
        let text: String
        let timeStamp: String
        let isSender: Bool
    }
    
    @State private var messages: [Message] = [
        // Sample data
        Message(text: "Hello sir, Good Morning", timeStamp: "09:30 am", isSender: true),
        Message(text: "Morning, Can I help you?", timeStamp: "09:31 am", isSender: false),
        Message(text: "I saw the UI/UX Designer vacancy that you uploaded on linkedin yesterday and I am interested in joining your company.", timeStamp: "09:33 am", isSender: true),
        Message(text: "Oh yes, please send your CV/Resume here", timeStamp: "09:35 am", isSender: false)
    ]
    
    @State private var newMessageText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Header
                VStack(spacing: 4) {
                    Text("You have no notifications at this time\nthank you")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // MARK: - Microphone
                Button(action: {
                    // You could trigger recording or any action here.
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image("mic")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 16)
                
                // MARK: - Chat ScrollView
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { msg in
                            if msg.isSender {
                                // Sender (User) bubble - Blue, aligned right
                                HStack {
                                    Spacer(minLength: 50)
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(msg.text)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.chat)
                                            .cornerRadius(8)
                                        
                                        Text(msg.timeStamp)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                            } else {
                                // Receiver (Bot) bubble - Gray, aligned left with avatar
                                HStack(alignment: .bottom, spacing: 8) {
                                    VStack {
                                        Image("logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.black)
                                            .background(Color.white)
                                            .clipShape(Circle())

                                        Text(msg.timeStamp)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(msg.text)
                                            .foregroundColor(.black)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                    
                                    Spacer(minLength: 50)
                                }

                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                
                // MARK: - Bottom bar
                HStack {
                    // Attachment Button
                    Button(action: {
                        // Handle attachment action
                    }) {
                        Image(systemName: "paperclip")
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 10)
                    
                    TextField("Write your message", text: $newMessageText)
                        .padding(.horizontal, 12)
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.chat, lineWidth: 2)
                        )
                    
                    // Send Button
                    Button(action: {
                        // Send the message
                        guard !newMessageText.isEmpty else { return }
                        let newMsg = Message(text: newMessageText,
                                             timeStamp: currentTimeStamp(),
                                             isSender: true)
                        messages.append(newMsg)
                        newMessageText = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.chat.opacity(0.9)) // Dark blue background
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
                .shadow(radius: 3)
            }
            .navigationBarTitle("Avia copilot", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    print("Back button clicked")
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
            )
        }
    }
    
    // Helper for time stamp
    func currentTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: Date())
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
