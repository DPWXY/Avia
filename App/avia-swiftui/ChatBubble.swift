import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading) {
                Text(message.content)
                    .padding(.vertical, 12)
                    .background(message.sender == .user ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(message.sender == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(message.timeString)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            if message.sender == .assistant {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
