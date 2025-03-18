import SwiftUI
import Amplify
import UIKit

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    let newSize = (widthRatio > heightRatio) ?
        CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
        CGSize(width: size.width * widthRatio, height: size.height * widthRatio)

    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let renderer = UIGraphicsImageRenderer(size: newSize, format: format)

    return renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
    }
}

class CreatePostViewModel: ObservableObject {
    @Published var title = ""
    @Published var content = ""
    @Published var selectedImage: UIImage?
    @Published var showingImagePicker = false
    @Published var duration = 0.0
    @Published var distance = 0.0
    
    // Access global user session
    private var userSession = UserSession.shared
    
    // Creates a local Post for immediate insertion into the Feed
    func createPost() -> Post? {
        guard let profile = userSession.pilotProfile else {
            print("Error: No user profile found.")
            return nil
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        
        return Post(
            author: PostAuthor(
                username: profile.username,
                userId: profile.userId,
                profileImage: nil  // Modify if user images are available
            ),
            title: title,
            date: dateFormatter.string(from: currentDate),
            content: content,
            image: selectedImage,
            duration: duration,
            distance: distance
        )
    }
    
    // Creates a PostData in AWS via Amplify
    func createPostAWS() async {
        guard let profile = userSession.pilotProfile else {
            print("Error: No user profile found.")
            return
        }

        // Convert UIImage to Base64 after resizing
        let base64Image: String?
        if let selectedImage = selectedImage {
            let resizedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 800, height: 800))
            if let imageData = resizedImage.jpegData(compressionQuality: 0.4) {
                base64Image = imageData.base64EncodedString()
            } else {
                base64Image = nil
            }
        } else {
            base64Image = nil
        }

        do {
            // Use the current date/time with Temporal.DateTime
            let now = Temporal.Date.now()

            let newPostData = PostData(
                username: profile.username,
                userId: profile.userId,
                title: title,
                content: content,
                uiImage: base64Image,
                date: now,
                duration: duration,
                distance: distance
            )

            let result = try await Amplify.API.mutate(request: .create(newPostData))
            switch result {
            case .success(let createdPost):
                print("✅ Successfully created PostData in AWS: \(createdPost)")
            case .failure(let error):
                print("❌ Failed to create PostData in AWS: \(error)")
            }
        } catch {
            print("❌ Unexpected error creating PostData: \(error)")
        }
    }
}

struct CreatePostView: View {
    @Binding var selectedTab: Int
    @Binding var posts: [Post]
    @StateObject private var viewModel = CreatePostViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    selectedTab = 0
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Text("Create Post")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.createPostAWS()
                        selectedTab = 0
                    }
                }) {
                    Text("Post")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.443, green: 0.816, blue: 0.816))
                        .cornerRadius(20)
                }
                .disabled(viewModel.title.isEmpty || viewModel.content.isEmpty)
            }
            .padding()
            .background(Color.black.opacity(0.3))
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Photo Section
                    Button(action: {
                        viewModel.showingImagePicker = true
                    }) {
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(16)
                                .overlay(
                                    Button(action: {
                                        viewModel.selectedImage = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .padding(8)
                                    }
                                    .padding(8),
                                    alignment: .topTrailing
                                )
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                Text("Add Photo")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Title Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal)
                        
                        TextField("Give your post a title", text: $viewModel.title)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                    }
                    
                    // Content Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal)
                        
                        TextField("What's happening in the sky?", text: $viewModel.content, axis: .vertical)
                            .lineLimit(5...10)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                    }
                    
                    // Flight Details
                    VStack(spacing: 16) {
                        // Flight Time
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Flight Time")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.white.opacity(0.6))
                                TextField("Duration", value: $viewModel.duration, format: .number)
                                    .keyboardType(.decimalPad)
                                Text("hours")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                        }
                        
                        // Flight Distance
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Flight Distance")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal)
                            
                            HStack {
                                Image(systemName: "airplane")
                                    .foregroundColor(.white.opacity(0.6))
                                TextField("Distance", value: $viewModel.distance, format: .number)
                                    .keyboardType(.decimalPad)
                                Text("nm")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 20)
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
        .sheet(isPresented: $viewModel.showingImagePicker) {
            ImagePicker(selectedImage: $viewModel.selectedImage)
        }
    }
}

// SwiftUI Previews
#Preview {
    CreatePostView(selectedTab: .constant(3), posts: .constant([]))
        .preferredColorScheme(.dark).environmentObject(UserSession.shared)
}
