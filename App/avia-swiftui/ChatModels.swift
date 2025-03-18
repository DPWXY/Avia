import Foundation

enum MessageSender {
    case user
    case assistant
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let sender: MessageSender
    let timestamp: Date
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
}
