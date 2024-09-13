//
//  ChatroomListView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/16/24.
//

import SwiftUI

struct ChatroomListView: View {
    @StateObject private var viewModel = ChatroomListViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient to match theme
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.05, green: 0.05, blue: 0.15)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.chatrooms.isEmpty {
                        // Custom Empty State
                        VStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                                .padding(.bottom, 20)
                            Text("No chatrooms available.")
                                .foregroundColor(.gray)
                                .italic()
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(viewModel.chatrooms) { chatroom in
                                NavigationLink(destination: ChatroomView(chatroomID: chatroom.id)) {
                                    HStack {
                                        Image(systemName: "message.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color(red: 0.3, green: 0.6, blue: 1.0))  // Softer blue
                                            .padding(.trailing, 10)
                                        
                                        VStack(alignment: .leading) {
                                            Text(chatroom.name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                            Text(chatroom.lastMessage)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding() // Keep the padding but ensure the background is clear
                                    .background(Color.clear)  // Make sure the row's background is clear
                                }
                                .listRowBackground(Color.clear) // Ensure each row has a clear background
                            }
                        }
                        .listStyle(PlainListStyle()) // Removes extra padding from the list
                        .background(Color.clear) // Makes sure the list background is clear
                    }
                }
                .navigationTitle("Gossip Here")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // Navigate to SettingsView when profile icon is tapped
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "person.circle.fill") // Profile icon
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                    }
                }
                .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                    Alert(
                        title: Text("Error"),
                        message: Text(viewModel.errorMessage ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.errorMessage = nil
                        }
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ChatroomListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatroomListView()
            .preferredColorScheme(.dark)  // To preview in dark mode
    }
}
