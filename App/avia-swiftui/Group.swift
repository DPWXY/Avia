import SwiftUI

struct GroupMember: Identifiable {
    let id = UUID()
    var name: String
    var profileImage: UIImage?
}

struct Group: Identifiable {
    let id = UUID()
    var name: String
    var profileImage: UIImage?
    var members: [GroupMember]
    
    var memberSummary: String {
        if members.isEmpty {
            return "No members"
        }
        
        let displayedMembers = members.prefix(2)
        let remainingCount = members.count - displayedMembers.count
        
        var summary = displayedMembers.map { $0.name }.joined(separator: ", ")
        if remainingCount > 0 {
            summary += " ... \(remainingCount) other member"
            if remainingCount > 1 {
                summary += "s"
            }
        }
        
        return summary
    }
}

struct GroupView: View {
    let group: Group
    
    var body: some View {
        HStack(spacing: 16) {
            // Group Icon/Image
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.443, green: 0.816, blue: 0.816),
                            Color(red: 0.2, green: 0.4, blue: 0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 56, height: 56)
                
                if let profileImage = group.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            
            // Group Info
            VStack(alignment: .leading, spacing: 6) {
                Text(group.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Member avatars and count
                HStack(spacing: -8) {
                    // Show first 3 member avatars
                    ForEach(group.members.prefix(3)) { member in
                        if let profileImage = member.profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 0.051, green: 0.043, blue: 0.267), lineWidth: 2)
                                )
                        } else {
                            Circle()
                                .fill(Color(red: 0.2, green: 0.4, blue: 0.6))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 0.051, green: 0.043, blue: 0.267), lineWidth: 2)
                                )
                        }
                    }
                    
                    // Member count
                    if group.members.count > 3 {
                        Text("+\(group.members.count - 3)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.443, green: 0.816, blue: 0.816).opacity(0.3))
                            .clipShape(Capsule())
                            .padding(.leading, 8)
                    }
                }
            }
            
            Spacer()
            
            // Join Status
            Circle()
                .fill(Color(red: 0.443, green: 0.816, blue: 0.816))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.2, green: 0.4, blue: 0.6).opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.443, green: 0.816, blue: 0.816).opacity(0.1), lineWidth: 1)
                )
        )
    }
}

