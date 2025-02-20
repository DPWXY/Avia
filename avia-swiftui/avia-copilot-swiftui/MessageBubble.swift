import SwiftUI

struct MessageBubble: View {
    let message: String
    let isFromUser: Bool
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            if isFromUser { Spacer() }
            
            Text(message)
                .font(.custom("DMSans-Regular", size: 13))
                .foregroundColor(isFromUser ? .white : .black)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    isFromUser ?
                        Color.blue.opacity(0.8) :
                        Color(red: 240/255, green: 240/255, blue: 240/255)
                )
                .cornerRadius(25)
                .scaleEffect(isAnimating ? 1 : 0)
                .opacity(isAnimating ? 1 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isAnimating = true
                    }
                }
            
            if !isFromUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

