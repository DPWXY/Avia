import SwiftUI

enum ChatType {
    case direct
    case group
}

struct Chat: Identifiable {
    let id = UUID()
    var name: String
    var lastMessage: String
    var timestamp: String
    var unreadCount: Int
    var type: ChatType
    var profileImage: UIImage?
}

class ChatsViewModel: ObservableObject {
    @Published var chats: [Chat] = [
        // Group chats
        Chat(
            name: "PPL Study Group",
            lastMessage: "Alex: Anyone up for a study session tonight?",
            timestamp: "2:30 PM",
            unreadCount: 3,
            type: .group,
            profileImage: nil
        ),
        Chat(
            name: "Bay Area Pilots",
            lastMessage: "Sarah: Weather's looking great for the weekend!",
            timestamp: "11:45 AM",
            unreadCount: 0,
            type: .group,
            profileImage: nil
        ),
        
        // Direct messages
        Chat(
            name: "John Smith",
            lastMessage: "Thanks for the flight tips!",
            timestamp: "Yesterday",
            unreadCount: 0,
            type: .direct,
            profileImage: nil
        ),
        Chat(
            name: "Sarah Chen",
            lastMessage: "Let's plan that cross country soon",
            timestamp: "Yesterday",
            unreadCount: 2,
            type: .direct,
            profileImage: nil
        )
    ]
}

struct ChatRow: View {
    let chat: Chat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Profile image
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.443, green: 0.816, blue: 0.816),
                                Color(red: 0.2, green: 0.4, blue: 0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 56, height: 56)
                    
                    if let profileImage = chat.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: chat.type == .group ? "person.3.fill" : "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                
                // Chat info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(chat.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(chat.timestamp)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    HStack {
                        Text(chat.lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if chat.unreadCount > 0 {
                            Text("\(chat.unreadCount)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.443, green: 0.816, blue: 0.816))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.2, green: 0.4, blue: 0.6).opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.443, green: 0.816, blue: 0.816).opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

struct ChatsView: View {
    @State private var activeChat: Chat = Chat(name: "", lastMessage: "", timestamp: "", unreadCount: 0, type: .group, profileImage: nil)
    @State private var showChatInterface = false
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @StateObject private var viewModel = ChatsViewModel()
    
    private func showChat(_ chat: Chat) {
        showChatInterface = false  // Force view refresh
        activeChat = chat
        DispatchQueue.main.async {
            showChatInterface = true
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Chats")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // New chat action
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .background(Color(red: 0.051, green: 0.043, blue: 0.267))
            
            // Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Search chats", text: $searchText)
                    .font(.body)
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .padding()
            
            // Chat list
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Group chats section
                    if !viewModel.chats.filter({ $0.type == .group }).isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Groups")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.chats.filter { $0.type == .group }) { chat in
                                ChatRow(chat: chat) {
                                    showChat(chat)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Direct messages section
                    if !viewModel.chats.filter({ $0.type == .direct }).isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Direct Messages")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.chats.filter { $0.type == .direct }) { chat in
                                ChatRow(chat: chat) {
                                    showChat(chat)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            /*
            // New Message Button
            Button(action: {
                // Add new message action
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("New Message")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.443, green: 0.816, blue: 0.816))
                .cornerRadius(16)
                .padding()
            }
            */
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.443, green: 0.816, blue: 0.816),  // Teal
                    Color(red: 0.2, green: 0.4, blue: 0.6),        // Mid blue
                    Color(red: 0.051, green: 0.043, blue: 0.267)   // Navy blue
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showChatInterface) {
            ChatInterfaceView(chat: activeChat)
        }
    }
}


#Preview {
    ChatsView()
        .preferredColorScheme(.dark)
}

