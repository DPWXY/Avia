import SwiftUI
import Amplify

// Decodable structs for the GraphQL response for posts.
struct ListPostDataResponse: Decodable {
    let listPostData: ListPostDataResult?
}

struct ListPostDataResult: Decodable {
    let items: [PostData]?
}

class FeedViewModel: ObservableObject {
    @Published var feedPosts: [Post] = []
    
    /// Fetch posts using a GraphQL query, convert to local Post,
    /// sort them (latest first), and limit to 50.
    func fetchPosts() async {
        await MainActor.run { self.feedPosts.removeAll() }
        let request = GraphQLRequest<ListPostDataResponse>(
            document: """
            query ListPostData {
                listPostData {
                    items {
                        id
                        username
                        userId
                        title
                        content
                        uiImage
                        duration
                        distance
                        likes
                        createdAt
                        updatedAt
                    }
                }
            }
            """,
            variables: nil,
            responseType: ListPostDataResponse.self
        )
        do {
            print("Fetching latest 50 posts from AWS...")
            let result = try await Amplify.API.query(request: request)
            switch result {
            case .success(let response):
                if let items = response.listPostData?.items {
                    print("AWS returned \(items.count) posts.")

                    let posts = items.compactMap { Post(from: $0) }

                    // Sort posts globally based on UTC `createdAt`
                    let sortedPosts = posts.sorted {
                        $0.createdAt > $1.createdAt
                    }

                    await MainActor.run {
                        self.feedPosts = Array(sortedPosts.prefix(50))
                        print("Updated feed with \(self.feedPosts.count) posts.")
                    }
                } else {
                    print("No posts found in AWS response.")
                }
            case .failure(let error):
                print("GraphQL query for posts failed: \(error)")
            }
        } catch {
            print("Unexpected error while fetching posts: \(error)")
        }
    }
}

struct FeedView: View {
    @Binding var personalPosts: [Post]
    @StateObject private var viewModel = FeedViewModel()
    @State private var showingChats = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {}) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Feed")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    showingChats = true
                }) {
                    Image(systemName: "message")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color(red: 0.051, green: 0.043, blue: 0.267))   // Dark Navy blue
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(personalPosts) { post in
                        PostView(post: post)
                            .padding(.horizontal)
                    }
                    ForEach(viewModel.feedPosts) { post in
                        PostView(post: post)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
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
        .sheet(isPresented: $showingChats) {
            ChatsView()
        }
        .onAppear {
            Task {
                await viewModel.fetchPosts()
            }
        }
    }
}

#Preview {
    FeedView(personalPosts: .constant([]))
        .preferredColorScheme(.dark)
}
