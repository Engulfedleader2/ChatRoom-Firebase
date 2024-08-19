//
//  ChatroomView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/10/24.
//

import SwiftUI

struct ChatroomView: View {
    @StateObject private var viewModel: ChatroomViewModel
    @State private var scrollToBottom = false
    
    init(chatroomID: String) {
        _viewModel = StateObject(wrappedValue: ChatroomViewModel(chatroomID: chatroomID))
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.messages) { message in
                            VStack(alignment: .leading) {
                                Text("\(message.username):")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                Text(message.message)
                                    .padding(.vertical, 4)
                                
                                Divider()
                            }
                            .padding(.horizontal)
                            .swipeActions(edge: .leading) {
                                Button {
                                    // Toggle or show the timestamp
                                    print("Timestamp: \(message.timestamp)")
                                } label: {
                                    Text(message.timestamp, style: .time)  // Display the time
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .onChange(of: viewModel.messages) { _ in
                        // Scroll to the bottom when new messages arrive
                        withAnimation {
                            scrollProxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                .padding(.top)
            }
            
            // Message Input
            HStack {
                TextField("Type your message...", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding()
                        .background(viewModel.newMessage.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(viewModel.newMessage.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chatroom")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChatroomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatroomView(chatroomID: "chatroom1")
    }
}
