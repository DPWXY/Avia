import SwiftUI

struct AviaView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.443, green: 0.816, blue: 0.816),
                    Color(red: 0, green: 0.29, blue: 0.561),
                    Color(red: 0.051, green: 0.043, blue: 0.267)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .center, spacing: 80) {
                    Text("AVIA")
                        .font(.custom("Prosto One", size: 64))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                    
                    AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/TEMP/42423d381316cb9c4cbd1612eb19d49afcbd3d4afd573c5f18873c2c2e855c45?placeholderIfAbsent=true&apiKey=550bbadecc70448d92c11acfaf8284a2&format=webp")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 210, height: 210)
                    
                    Text("YOUR DIGITAL COPILOT")
                        .font(.custom("Marcellus", size: 14))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                    
                    Button(action: {
                        // Action to perform when button is tapped
                    }) {
                        Text("GET STARTED")
                            .font(.custom("ABeeZee", size: 16))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                            .background(Color(red: 0.816, green: 0.816, blue: 0.816, opacity: 0.3))
                            .cornerRadius(30)
                    }
                    .accessibilityLabel("Get started with Avia")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 82)
                .padding(.vertical, 50)
            }
            .scrollDisabled(true)
        }
    }
}

struct AviaView_Previews: PreviewProvider {
    static var previews: some View {
        AviaView()
    }
}
