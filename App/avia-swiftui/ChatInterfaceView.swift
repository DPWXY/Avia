import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let senderName: String
    let isCurrentUser: Bool
}

class ChatInterfaceViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessageText = ""
    let chat: Chat
    
    init(chat: Chat) {
        self.chat = chat
        // Initialize messages based on chat type
        if chat.type == .group {
            // Group chat messages with multiple participants
            messages = [
                Message(content: "Hey everyone! Who's up for a study session tonight?",
                       timestamp: Date().addingTimeInterval(-7200),
                       senderName: "Alex Chen",
                       isCurrentUser: false),
                Message(content: "I'm in! Need to review VOR navigation.",
                       timestamp: Date().addingTimeInterval(-7000),
                       senderName: "Sarah Miller",
                       isCurrentUser: false),
                Message(content: "Count me in too! Could use help with weather briefings.",
                       timestamp: Date().addingTimeInterval(-6800),
                       senderName: "You",
                       isCurrentUser: true),
                Message(content: "Great! Let's meet at 7 PM at the usual spot.",
                       timestamp: Date().addingTimeInterval(-6600),
                       senderName: "Alex Chen",
                       isCurrentUser: false),
                Message(content: "I can bring some practice charts.",
                       timestamp: Date().addingTimeInterval(-6400),
                       senderName: "Mike Johnson",
                       isCurrentUser: false),
                Message(content: "Perfect! See you all then.",
                       timestamp: Date().addingTimeInterval(-6200),
                       senderName: "Sarah Miller",
                       isCurrentUser: false),
                Message(content: "Don't forget your E6B flight computers!",
                       timestamp: Date().addingTimeInterval(-6000),
                       senderName: "You",
                       isCurrentUser: true)
            ]
        } else {
            // Direct message conversation
            messages = [
                Message(content: "Hey there!",
                       timestamp: Date().addingTimeInterval(-3600),
                       senderName: "You",
                       isCurrentUser: true),
                Message(content: "Hi! How's your flight training going?",
                       timestamp: Date().addingTimeInterval(-3500),
                       senderName: chat.name,
                       isCurrentUser: false),
                Message(content: "It's going great! Just completed my cross-country flight.",
                       timestamp: Date().addingTimeInterval(-3400),
                       senderName: "You",
                       isCurrentUser: true)
            ]
        }
    }
    
    func sendMessage() {
        guard !newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = Message(
            content: newMessageText,
            timestamp: Date(),
            senderName: "You",
            isCurrentUser: true
        )
        
        messages.append(newMessage)
        newMessageText = ""
    }
}

struct ChatInterfaceView: View {
    let chat: Chat
    @StateObject private var viewModel: ChatInterfaceViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    
    init(chat: Chat) {
        self.chat = chat
        _viewModel = StateObject(wrappedValue: ChatInterfaceViewModel(chat: chat))
    }
    
    var body: some View {
        ZStack {
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
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    if let profileImage = chat.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: viewModel.chat.type == .group ? "person.3.fill" : "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    
                    Text(chat.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if viewModel.chat.type == .group {
                        Button(action: {
                            // Show group info/members
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                
                // Messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 2) {
                                if !message.isCurrentUser {
                                    Text(message.senderName)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 2)
                                }
                                
                                MessageBubble(message: message.content, isFromUser: message.isCurrentUser)
                                
                                Text(message.timestamp, style: .time)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.horizontal, 16)
                                    .padding(.top, 2)
                            }
                        }
                    }
                    .padding()
                }
                
                // Message input
                HStack(spacing: 12) {
                    TextField("Message", text: $viewModel.newMessageText)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    
                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .disabled(viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.3))
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ChatInterfaceView(chat: Chat(name: "Preview Chat", lastMessage: "Test", timestamp: "Now", unreadCount: 0, type: .group, profileImage: nil))
}



