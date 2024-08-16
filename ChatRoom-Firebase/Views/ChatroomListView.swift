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
            List {
                if viewModel.chatrooms.isEmpty {
                    Text("No chatrooms available.")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(viewModel.chatrooms) { chatroom in
                        NavigationLink(destination: ChatroomView(chatroomID: chatroom.id)) {
                            VStack(alignment: .leading) {
                                Text(chatroom.name)
                                    .font(.headline)
                                Text(chatroom.lastMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chatrooms")
            .onAppear {
                if viewModel.chatrooms.isEmpty {
                    viewModel.errorMessage = "No chatrooms available."
                }
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct ChatroomListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatroomListView()
    }
}
