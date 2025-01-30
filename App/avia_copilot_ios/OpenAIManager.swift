import Foundation
import OpenAIKit

public class OpenAIManager {
    private let openAI: OpenAIKit.Client
    
    public init(apiKey: String) {
        self.openAI = OpenAIKit.Client(apiToken: apiKey)
    }
    
    public func generateResponse(for text: String) async throws -> String {
        let chat = Chat(
            messages: [.init(role: .user, content: text)],
            model: .gpt3_5Turbo
        )
        
        let result = try await openAI.chats.create(chat)
        return result.choices.first?.message.content ?? "Sorry, I couldn't generate a response."
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}


