import SwiftUI
import Amplify

// Local Post author structure.
struct PostAuthor: Identifiable {
    let id = UUID().uuidString
    var username: String
    var userId: String
    var profileImage: UIImage?
}

// Local Post model with a createdAt property.
struct Post: Identifiable {
    let id = UUID().uuidString
    var author: PostAuthor
    var title: String
    var date: String  // Display date (e.g., "02/24")
    var content: String
    private var uiImage: UIImage?
    var image: Image? {
        if let uiImage = uiImage {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    var createdAt: Date  // Used for sorting posts
    var duration: Double
    var distance: Double
    
    init(author: PostAuthor, title: String, date: String, content: String, image: UIImage? = nil, createdAt: Date = Date(), duration: Double, distance: Double) {
        self.author = author
        self.title = title
        self.date = date
        self.content = content
        self.uiImage = image
        self.createdAt = createdAt
        self.duration = duration
        self.distance = distance
    }
}

// PostView for displaying a post.
struct PostView: View {
    let post: Post
    let isProfileView: Bool
    
    init(post: Post, isProfileView: Bool = false) {
        self.post = post
        self.isProfileView = isProfileView
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                // Date and Title
                VStack(alignment: .leading, spacing: 8) {
                    if !isProfileView {
                        // Author header for feed view
                        HStack(spacing: 12) {
                            if let profileImage = post.author.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(post.author.username)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("@\(post.author.userId)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Text(post.date)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        // Simple header for profile view
                        HStack {
                            Text(post.date)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                        }
                    }
                    
                    Text(post.title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                // Content
                Text(post.content)
                    .font(.body)
                    .foregroundColor(.white)
                
                // Flight information
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.white.opacity(0.7))
                        Text(String(format: "%.1f hrs", post.duration))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "airplane")
                            .foregroundColor(.white.opacity(0.7))
                        Text(String(format: "%.0f nm", post.distance))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.top, 4)
                
                if let image = post.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                }
                
                // Action buttons
                HStack(spacing: 20) {
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "arrowshape.turn.up.right")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .cornerRadius(16)

        }
}

extension Post {
    init(from postData: PostData) {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Supports milliseconds

        let postDateUTC: Date
        if let temporalDate = postData.createdAt {
            postDateUTC = isoFormatter.date(from: temporalDate.iso8601String) ?? Date()
        } else {
            postDateUTC = Date()
        }

        // Convert UTC date to user's local time zone for display
        let localFormatter = DateFormatter()
        localFormatter.dateFormat = "MM/dd HH:mm:ss" // Includes seconds for accurate display
        localFormatter.timeZone = TimeZone.current   // Converts UTC to device's time zone
        let displayDate = localFormatter.string(from: postDateUTC)

        // Decode Base64 image from AWS
        var decodedImage: UIImage? = nil
        if let base64String = postData.uiImage,
           let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
           let uiImage = UIImage(data: imageData) {
            decodedImage = uiImage
        }

        self.init(
            author: PostAuthor(
                username: postData.username ?? "Unknown",
                userId: postData.userId ?? "Unknown",
                profileImage: nil
            ),
            title: postData.title ?? "(No Title)",
            date: displayDate, // Displayed in the user's local time
            content: postData.content ?? "",
            image: decodedImage,
            createdAt: postDateUTC, // Storing in UTC for global sorting
            duration: postData.duration ?? 0.0,
            distance: postData.distance ?? 0.0
        )
    }
}


