//
//  ContentView.swift
//  avia-copilot-swiftui
//
//  Created by Rana Taki on 2/17/25.
//

import SwiftUI

struct ContentView: View {
    @State private var messageText: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                notificationsView
                messagesView
                inputView
            }
            .padding(.vertical, 42)
            .frame(maxWidth: 480)
            .background(Color(red: 249/255, green: 249/255, blue: 249/255))
            .cornerRadius(30)
        }
        .background(Color(red: 249/255, green: 249/255, blue: 249/255))
        .edgesIgnoringSafeArea(.all)
    }

    private var headerView: some View {
        VStack(spacing: 9) {
            Text("Avia copilot")
                .font(.custom("DMSans-Bold", size: 16))
            Text("You have no notifications at this time thank you")
                .font(.custom("DMSans-Regular", size: 12))
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.black)
        .padding(.horizontal, 20)
        .padding(.leading, 55)
    }

    private var notificationsView: some View {
        VStack(alignment: .trailing, spacing: 5) {
            AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/TEMP/79d92d10cc9050f1ca2d3945e70fa13bee2268a0f2e9b785f237849ad650aba8?placeholderIfAbsent=true&apiKey=550bbadecc70448d92c11acfaf8284a2&format=webp")) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 173, height: 171)
            .padding(.top, 25)

            ZStack(alignment: .leading) {
                AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/TEMP/dfd62448ba51bb3c43545296b9817a73b9a3a340ea76f6a828db4ede112b8230?placeholderIfAbsent=true&apiKey=550bbadecc70448d92c11acfaf8284a2&format=webp")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }

                Text("Hello sir, Good Morning")
                    .font(.custom("DMSans-Regular", size: 13))
                    .foregroundColor(Color(red: 1/255, green: 1/255, blue: 1/255))
                    .padding(.horizontal, 33)
                    .padding(.vertical, 16)
            }
            .frame(height: 50)
            .cornerRadius(25)

            Text("09:30 am")
                .font(.custom("DMSans-Regular", size: 10))
                .foregroundColor(Color(red: 1/255, green: 1/255, blue: 1/255))
        }
        .padding(.horizontal, 20)
        .padding(.leading, 55)
    }

    private var messagesView: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .top, spacing: 10) {
                AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/TEMP/657ab6bcaed1a0fdf85e0f4ae86768155fe70f299c6ae4bade57cd809a3a1e9e?placeholderIfAbsent=true&apiKey=550bbadecc70448d92c11acfaf8284a2&format=webp")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 35, height: 35)
                .clipShape(Circle())

                ZStack(alignment: .leading) {
                    AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/TEMP/b77a63c6593528dbfb5b41d44d00f016055f2be10ba5f7b8e31ae198c1a2d63e?placeholderIfAbsent=true&apiKey=550bbadecc70448d92c11acfaf8284a2&format=webp")) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }

                    Text("Morning, Can i help you ?")
                        .font(.custom("DMSans-Regular", size: 13))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                }
                .frame(height: 50)
                .cornerRadius(25)
            }

            Text("09:31 am")
                .font(.custom("DMSans-Regular", size: 10))
                .foregroundColor(Color(red: 1/255, green: 1/255, blue: 1/255))
                .padding(.leading, 45)

            ZStack(alignment: .leading) {
                AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/TEMP/d3594f5004e1f92d9926240a25114c90266af410e411714f41fe2ee51c33af81?placeholderIfAbsent=true&apiKey=550bbadecc70448d92c11acfaf8284a2&format=webp")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }

                Text("I saw the UI/UX Designer vacancy that you uploaded on linkedin yesterday and I am interested in joining your company.")
                    .font(.custom("DMSans-Regular", size: 13))
                    .foregroundColor(Color(red: 1/255, green: 1/255, blue: 1/255))
                    .lineSpacing(7)
                    .padding(15)
            }
            .frame(maxWidth: 261, alignment: .trailing)
            .cornerRadius(25)

            Text("09:33 am")
                .font(.custom("DMSans-Regular", size: 10))
                .foregroundColor(Color(red: 1/255, green: 1/255, blue: 1/255))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 20)
    }

    private var inputView: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .bottom, spacing: 10) {
                AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/TEMP/657ab6bcaed1a0fdf85e0f4ae86768155fe70f299c6ae4bade57cd809a3a1e9e?placeholderIfAbsent=true&apiKey=550bbadecc70448d92c11acfaf8284a2&format=webp")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 35, height: 35)
                .clipShape(Circle())

                ZStack(alignment: .leading) {
                    AsyncImage(url: URL(string: "https://cdn.builder.io/api/v1/image/assets/TEMP/13327141e2bddf78b5fb3952cb546d1e627431063c8bfd8b4073c20b2e0442fd?placeholderIfAbsent=true&apiKey=550bbadecc70448d92c11acfaf8284a2&format=webp")) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }

                    Text("Oh yes, please send your CV/Resume here")
                        .font(.custom("DMSans-Regular", size: 13))
                        .foregroundColor(.black)
                        .lineSpacing(7)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 13)
                }
                .frame(width: 192, height: 66)
                .cornerRadius(25)
            }

            Text("09:35 am")
                .font(.custom("DMSans-Regular", size: 10))
                .foregroundColor(Color(red: 1/255, green: 1/255, blue: 1/255))
                .padding(.leading, 45)

            TextField("Write your message", text: $messageText)
                .font(.custom("DMSans-Regular", size: 12))
                .padding(.horizontal, 59)
                .padding(.vertical, 17)
                .background(Color.white)
                .cornerRadius(15)
                .accessibility(label: Text("Message input"))
        }
        .padding(.horizontal, 20)
        .padding(.trailing, 55)
        .padding(.top, 34)
    }
}

struct AviaCopilotView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

