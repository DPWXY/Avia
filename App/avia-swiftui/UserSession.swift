import SwiftUI
import Amplify

// Structures for decoding the GraphQL response.
struct ListProfilesResponse: Decodable {
    let listProfiles: ListProfilesResult?
}

struct ListProfilesResult: Decodable {
    let items: [Profile]?
}

final class UserSession: ObservableObject {
    static let shared = UserSession()
    
    @Published var pilotProfile: PilotProfile?
    
    private init() { }
    
    /// Loads a profile for the given username using a GraphQL query.
    /// Returns true if a profile is found and loaded; false otherwise.
    func loadProfileAPI(for userId: String) async -> Bool {
        let request = GraphQLRequest<ListProfilesResponse>(
            document: """
            query ListProfiles($filter: ModelProfileFilterInput) {
                listProfiles(filter: $filter) {
                    items {
                        id
                        username
                        userId
                        profileImage
                        rank
                        hours
                        followers
                        groups
                    }
                }
            }
            """,
            variables: ["filter": ["userId": ["eq": userId]]],
            responseType: ListProfilesResponse.self
        )
        do {
            let result = try await Amplify.API.query(request: request)
            switch result {
            case .success(let response):
                if let items = response.listProfiles?.items,
                   let awsProfile = items.first {
                    DispatchQueue.main.async {
                        self.pilotProfile = PilotProfile(from: awsProfile)
                    }
                    print("Successfully loaded profile: \(awsProfile)")
                    return true
                } else {
                    print("Profile not found for userId: \(userId)")
                    return false
                }
            case .failure(let error):
                print("GraphQL query failed: \(error)")
                return false
            }
        } catch {
            print("Unexpected error while querying profile: \(error)")
            return false
        }
    }
}
