import SwiftUI

struct MessageBubble: View {
    let message: String
    let isFromUser: Bool
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            if isFromUser { Spacer() }
            
            Text(message)
                .font(.body)
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isFromUser ? Color.blue.opacity(0.8) : Color.white.opacity(0.1))
                )
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isFromUser ? .trailing : .leading)
                .scaleEffect(isAnimating ? 1 : 0)
                .opacity(isAnimating ? 1 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isAnimating = true
                    }
                }
            
            if !isFromUser { Spacer() }
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        MessageBubble(message: "Hey everyone! Who's up for a study session tonight?", isFromUser: false)
        MessageBubble(message: "Count me in! Need help with weather briefings.", isFromUser: true)
    }
    .padding()
    .preferredColorScheme(.dark)
    .background(Color(red: 0.051, green: 0.043, blue: 0.267))
}
