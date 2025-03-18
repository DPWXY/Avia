import Amplify
import AWSAPIPlugin
import Authenticator
import AWSCognitoAuthPlugin
import SwiftUI
import AWSDataStorePlugin

@main
struct avia_swiftuiApp: App {
    public init() {
        let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
        let apiPlugin = AWSAPIPlugin(modelRegistration: AmplifyModels()) // UNCOMMENT once backend is deployed

        do {
            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.add(plugin: apiPlugin) // UNCOMMENT once backend is deployed
            try Amplify.configure()
            print("Initialized Amplify")
        } catch {
            print("Could not initialize Amplify: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(UserSession.shared)
        }
    }
}

