import SwiftUI
import Amplify

struct ContentView: View {
    @State private var username = ""
    @State private var userId = ""
    @State private var isSignedIn = false
    @State private var errorMessage: String?
    
    // Registration state
    @State private var isRegistering = false
    @State private var registrationUsername = ""
    @State private var registrationRank = ""
    
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        if isSignedIn {
            AviaView()
                .environmentObject(userSession)
        } else {
            if isRegistering {
                registrationView
            } else {
                signInView
            }
        }
    }
    
    var signInView: some View {
        VStack(spacing: 20) {
            Text("Welcome to Avia!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Enter User Id", text: $userId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Button("Sign In", action: signIn)
                .frame(width: 200)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
    }
    
    var registrationView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("User Id: \(userId)")
                    .font(.headline)
                
                TextField("Enter usernmae", text: $registrationUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Enter Rank", text: $registrationRank)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Button("Register", action: registerProfile)
                    .frame(width: 200)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                
                Spacer()
            }
            .navigationBarTitle("Register", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                isRegistering = false
            }, label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }))
        }
    }
    
    /// Checks if a profile exists using a GraphQL query.
    func checkIfProfileExistsAPI() async throws -> Bool {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1-second delay (adjust if needed)
        
        let request = GraphQLRequest<ListProfilesResponse>(
            document: """
            query ListProfiles($filter: ModelProfileFilterInput) {
                listProfiles(filter: $filter) {
                    items {
                        id
                        userId
                    }
                }
            }
            """,
            variables: ["filter": ["userId": ["eq": userId]]],
            responseType: ListProfilesResponse.self
        )
        let result = try await Amplify.API.query(request: request)
        switch result {
        case .success(let response):
            let exists = (response.listProfiles?.items?.isEmpty == false)
            print("API query found profile: \(exists)")
            return exists
        case .failure(let error):
            print("GraphQL query failed: \(error)")
            throw error
        }
    }
    
    /// Sign in: If the profile exists, load it and then mark as signed in.
    func signIn() {
        Task {
            do {
                let exists = try await checkIfProfileExistsAPI()
                if exists {
                    let loaded = await userSession.loadProfileAPI(for: userId)
                    if loaded {
                        DispatchQueue.main.async {
                            isSignedIn = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "Failed to load profile."
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        isRegistering = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    /// Registers a new profile and loads it into the session.
    func registerProfile() {
        Task {
            do {
                try await PilotProfileManager.shared.createProfile(
                    PilotProfile(
                        username: registrationUsername,
                        userId: userId,
                        rank: registrationRank,
                        hours: 0,
                        followers: 0,
                        groups: 0
                    )
                )
                let loaded = await userSession.loadProfileAPI(for: userId)
                if loaded {
                    DispatchQueue.main.async {
                        isSignedIn = true
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "Profile created but failed to load."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(UserSession.shared)
}
