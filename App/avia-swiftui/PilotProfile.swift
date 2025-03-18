import SwiftUI
import Amplify

// MARK: - Local Model

class PilotProfile: Identifiable, ObservableObject {
    let id = UUID()
    @Published var username: String
    @Published var userId: String
    @Published var rank: String
    @Published var hours: Int
    @Published var followers: Int
    @Published var groups: Int
    @Published var profileImage: UIImage?
    
    init(username: String, userId: String, rank: String, hours: Int, followers: Int, groups: Int, profileImage: UIImage? = nil) {
        self.username = username
        self.userId = userId
        self.rank = rank
        self.hours = hours
        self.followers = followers
        self.groups = groups
        self.profileImage = profileImage
    }
}

// MARK: - Extension for Conversion

extension PilotProfile {
    /// Initialize a PilotProfile from an Amplify Profile model.
    convenience init(from awsProfile: Profile) {
        self.init(username: awsProfile.username ?? "No username",
                  userId: awsProfile.userId ?? "No userId",
                  rank: awsProfile.rank ?? "No Rank",
                  hours: awsProfile.hours ?? 0,
                  followers: awsProfile.followers ?? 0,
                  groups: awsProfile.groups ?? 0,
                  profileImage: nil) // Optionally load the image later using awsProfile.imageKey
    }
    
    /// Convert this PilotProfile into an Amplify Profile model.
    func toAWSProfile() -> Profile {
        // Include an empty array for PostData to satisfy the schema.
        return Profile(id: id.uuidString,
                       username: username,
                       userId: userId,
                       profileImage: "your_image_key_placeholder",
                       rank: rank,
                       hours: hours,
                       followers: followers,
                       groups: groups
                       )
    }
}

// MARK: - Profile Header View

enum SheetType: Identifiable {
    case imagePicker
    case chats
    
    var id: Int {
        switch self {
        case .imagePicker: return 0
        case .chats: return 1
        }
    }
}

struct ProfileHeaderView: View {
    @ObservedObject var profile: PilotProfile
    @State private var selectedImage: UIImage?
    @State private var activeSheet: SheetType?
    
    var body: some View {
        VStack(spacing: 16) {
            // Top buttons
            HStack {
                Button(action: {}) {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                }
                Spacer()
                Button(action: {
                    activeSheet = .chats
                }) {
                    Image(systemName: "message")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            // Profile section
            VStack(spacing: 8) {
                Button(action: { activeSheet = .imagePicker }) {
                    if let profileImage = profile.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .background(Color.blue)
                        .clipShape(Circle())
                        .offset(x: 5, y: 5)
                }
                
                Text(profile.username)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("@\(profile.userId)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(profile.rank)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Stats section
            HStack(spacing: 30) {
                VStack {
                    Text("\(profile.hours)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Hours")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                VStack {
                    Text("\(profile.followers)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                VStack {
                    Text("\(profile.groups)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Groups")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .sheet(item: $activeSheet) { type in
            switch type {
            case .imagePicker:
                ImagePicker(selectedImage: Binding(
                    get: { selectedImage },
                    set: { newImage in
                        selectedImage = newImage
                        if let newImage = newImage {
                            profile.profileImage = newImage
                        }
                    }
                ))
            case .chats:
                ChatsView()
            }
        }
    }
}

// MARK: - PilotProfileManager for AWS Networking
class PilotProfileManager {
    static let shared = PilotProfileManager()
    
    /// Create a new profile on AWS.
    func createProfile(_ profile: PilotProfile) async throws {
        let awsProfile = profile.toAWSProfile()
        let result = try await Amplify.API.mutate(request: .create(awsProfile))
        switch result {
        case .success(let model):
            print("Successfully created Profile: \(model)")
        case .failure(let graphQLError):
            print("Failed to create Profile: \(graphQLError)")
            throw graphQLError
        }
    }
    
    /// Update an existing profile on AWS.
    func updateProfile(_ profile: PilotProfile) async throws {
        let awsProfile = profile.toAWSProfile()
        let result = try await Amplify.API.mutate(request: .update(awsProfile))
        switch result {
        case .success(let model):
            print("Successfully updated Profile: \(model)")
        case .failure(let error):
            print("Failed to update Profile: \(error)")
            throw error
        }
    }
    
    /// Fetch a profile from AWS using the given id.
    func fetchProfile(byId id: String) async -> PilotProfile? {
        do {
            let result = try await Amplify.API.query(request: .get(Profile.self, byId: id))
            switch result {
            case .success(let awsProfile):
                guard let awsProfile = awsProfile else {
                    print("Profile not found")
                    return nil
                }
                return PilotProfile(from: awsProfile)
            case .failure(let error):
                print("Error fetching profile: \(error)")
                return nil
            }
        } catch {
            print("Error fetching profile: \(error)")
            return nil
        }
    }
}
