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
                                        .foregroundColor(.blue)
                                        .padding(.trailing, 10)
                                    VStack(alignment: .leading) {
                                        Text(chatroom.name) // Displaying the chatroom name
                                            .font(.headline)
                                        Text(chatroom.lastMessage)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemBackground).opacity(0.2)))
                                .shadow(radius: 1)
                            }
                        }
                        .listRowSeparator(.hidden) // Hides the default separator
                    }
                    .listStyle(PlainListStyle()) // Removes the extra padding on the list
                }
            }
            .navigationTitle("Chatrooms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action to add a new chatroom
                    }) {
                        Image(systemName: "plus")
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
        .navigationBarBackButtonHidden(true)
    }
}

struct ChatroomListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatroomListView()
    }
}
