import SwiftUI
import Amplify

// MARK: - AWS Helper Extensions

extension Temporal.DateTime {
    var asDate: Date? {
        ISO8601DateFormatter().date(from: self.iso8601String)
    }
}

extension Temporal.Date {
    var asDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Adjust if your format differs.
        return formatter.date(from: self.iso8601String)
    }
}

// MARK: - AviaView

struct AviaView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var selectedTab = 0
    // Start with sample posts for the FeedView.
    @State private var posts: [Post] = []
    
    var body: some View {
        ZStack {
            // Background gradient style
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.443, green: 0.816, blue: 0.816),
                    Color(red: 0, green: 0.29, blue: 0.561),
                    Color(red: 0.051, green: 0.043, blue: 0.267)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content for each tab.
                if selectedTab == 0 {
                    // Feed view using sample posts.
                    FeedView(personalPosts: $posts)
                } else if selectedTab == 4 {
                    // Profile view: load from AWS if a pilotProfile exists.
                    if let profile = userSession.pilotProfile {
                        VStack(spacing: 0) {
                            // Header
                            ProfileHeaderView(profile: profile)
                            
                            // Body: load posts for the current profile.
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(posts) { post in
                                        PostView(post: post, isProfileView: true)
                                            .padding(.horizontal)
                                    }
                                }
                                .padding(.vertical)
                            }
                            .background(Color.clear)
                            .task {
                                await loadProfilePosts(for: profile)
                            }
                        }
                    } else {
                        Text("Loading profile...")
                            .foregroundColor(.white)
                    }
                } else if selectedTab == 2 {
                    AviaCopilotView(selectedTab: $selectedTab)
                } else if selectedTab == 1 {
                    GroupsView()
                } else if selectedTab == 3 {
                    CreatePostView(selectedTab: $selectedTab, posts: $posts)
                } else {
                    Spacer()
                    Text("Coming soon!")
                        .foregroundColor(.white)
                    Spacer()
                }
                
                // Footer with tab buttons
                HStack(spacing: 0) {
                    ForEach(0..<5) { index in
                        Button(action: {
                            withAnimation {
                                selectedTab = index
                            }
                        }) {
                            VStack {
                                // For tab 2, show a larger mic icon with a background circle.
                                if index == 2 {
                                    Image(systemName: "mic.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .fill(selectedTab == index ? Color.blue : Color.clear)
                                                .frame(width: 50, height: 50)
                                        )
                                } else {
                                    Image(systemName: footerIcon(for: index))
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(red: 0.051, green: 0.043, blue: 0.267)) // Dark Navy blue footer background.
            }
        }
    }
    
    // MARK: - Footer Icon Helper
    
    private func footerIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "person.2.fill"
        case 2: return "mic.fill"
        case 3: return "plus.app.fill"
        case 4: return "person.crop.circle.fill"
        default: return ""
        }
    }
    
    // MARK: - AWS Post Loading Functionality
    
    /// Loads posts from AWS filtered by the current user's id.
    private func loadProfilePosts(for profile: PilotProfile) async {
        let userId = profile.userId
        
        let request = GraphQLRequest<ListPostDataResponse>(
            document: """
            query ListProfilePosts($userId: String!) {
                listPostData(filter: { userId: { eq: $userId } }) {
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
            variables: ["userId": userId],
            responseType: ListPostDataResponse.self
        )
        
        do {
            print("Fetching profile posts for user \(userId)...")
            let result = try await Amplify.API.query(request: request)
            switch result {
            case .success(let response):
                if let items = response.listPostData?.items {
                    // Sort the posts using the 'date' property (or fallback to 'createdAt').
                    let sortedPosts = items.sorted { first, second in
                        let firstDate = first.date?.asDate ?? first.createdAt?.asDate ?? Date.distantPast
                        let secondDate = second.date?.asDate ?? second.createdAt?.asDate ?? Date.distantPast
                        return firstDate > secondDate
                    }
                    // Map the Amplify model to your local Post type.
                    let mappedPosts = sortedPosts.map { Post(from: $0) }
                    await MainActor.run {
                        self.posts = mappedPosts
                    }
                } else {
                    print("No posts found for user \(userId)")
                }
            case .failure(let error):
                print("Error fetching profile posts: \(error)")
            }
        } catch {
            print("Unexpected error fetching profile posts: \(error)")
        }
    }
}

// MARK: - Preview

struct AviaView_Previews: PreviewProvider {
    static var previews: some View {
        AviaView().environmentObject(UserSession.shared)
    }
}
