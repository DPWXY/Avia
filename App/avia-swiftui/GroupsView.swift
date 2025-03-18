import SwiftUI

class GroupsViewModel: ObservableObject {
    @Published var groups: [Group] = [
        Group(
            name: "PPL Study Group",
            profileImage: nil,
            members: [
                GroupMember(name: "Rana Taki", profileImage: nil),
                GroupMember(name: "John Smith", profileImage: nil),
                GroupMember(name: "Sarah Chen", profileImage: nil),
                GroupMember(name: "Mike Johnson", profileImage: nil),
                GroupMember(name: "Emma Davis", profileImage: nil)
            ]
        ),
        Group(
            name: "Bay Area Pilots",
            profileImage: nil,
            members: [
                GroupMember(name: "Rana Taki", profileImage: nil),
                GroupMember(name: "Alex Wong", profileImage: nil),
                GroupMember(name: "Lisa Park", profileImage: nil),
                GroupMember(name: "David Miller", profileImage: nil),
                GroupMember(name: "James Wilson", profileImage: nil),
                GroupMember(name: "Anna Lee", profileImage: nil)
            ]
        ),
        Group(
            name: "Flight Sim Enthusiasts",
            profileImage: nil,
            members: [
                GroupMember(name: "Rana Taki", profileImage: nil),
                GroupMember(name: "Chris Taylor", profileImage: nil),
                GroupMember(name: "Maria Garcia", profileImage: nil),
                GroupMember(name: "Tom Anderson", profileImage: nil)
            ]
        )
    ]
}

struct GroupsView: View {
    @StateObject private var viewModel = GroupsViewModel()
    @State private var showingChats = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Groups")
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
            }
            .background(Color(red: 0.051, green: 0.043, blue: 0.267))   // Dark Navy blue
            
            // Body
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.groups) { group in
                        GroupView(group: group)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            
            // Create Group Button
            Button(action: {
                // Add create group action
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("Create New Group")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.443, green: 0.816, blue: 0.816))
                .cornerRadius(16)
                .padding()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.443, green: 0.816, blue: 0.816),  // Teal
                    Color(red: 0.2, green: 0.4, blue: 0.6),        // Mid blue
                    Color(red: 0.051, green: 0.043, blue: 0.267)   // Navy blue
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showingChats) {
            ChatsView()
        }
    }
}

#Preview {
    GroupsView()
        .preferredColorScheme(.dark)
}

