//
//  ChatroomView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/10/24.
//

import SwiftUI

struct ChatroomView: View {
    @StateObject private var viewModel: ChatroomViewModel
    @State private var showTimestampForMessageID: String? = nil  // Track which message's timestamp should be shown
    
    init(chatroomID: String) {
        _viewModel = StateObject(wrappedValue: ChatroomViewModel(chatroomID: chatroomID))
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            HStack {
                                // Show the clock icon only when the timestamp is visible
                                if showTimestampForMessageID == message.id {
                                    Image(systemName: "clock")
                                        .foregroundColor(.blue)
                                        .transition(.move(edge: .leading))
                                        .animation(.easeInOut, value: showTimestampForMessageID)
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    // Display the message content
                                    Text("\(message.username):")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    
                                    Text(message.message)
                                        .padding(10)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(8)
                                    
                                    // Conditionally show the timestamp when swiped right
                                    if showTimestampForMessageID == message.id {
                                        Text("\(message.timestamp, formatter: dateFormatter)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding(.top, 5)
                                            .transition(.opacity)
                                            .animation(.easeInOut, value: showTimestampForMessageID)
                                    }
                                }
                                .padding(.horizontal)
                                .contentShape(Rectangle()) // Make the whole area tappable
                                .gesture(
                                    DragGesture(minimumDistance: 30)
                                        .onEnded { value in
                                            if value.translation.width > 0 {
                                                // Swiped to the right, show the timestamp
                                                withAnimation {
                                                    showTimestampForMessageID = message.id
                                                }
                                            }
                                        }
                                )
                            }
                        }
                    }
                    .onChange(of: viewModel.messages) { _ in
                        // Scroll to the bottom when new messages arrive
                        withAnimation {
                            if let lastMessage = viewModel.messages.last {
                                scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .padding(.top)
            }
            
            // Message Input
            HStack {
                TextField("Type your message...", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .frame(minHeight: 30)
                
                Button(action: {
                    viewModel.sendMessage()
                    showTimestampForMessageID = nil  // Reset the timestamp visibility when sending a new message
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
            .background(Color(UIColor.systemGray5))
        }
        .navigationTitle("Chatroom")
        .navigationBarTitleDisplayMode(.inline)
        // Removed the code that hides the back button
    }
    
    // Date formatter for displaying date and time
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct ChatroomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatroomView(chatroomID: "chatroom1")
            .preferredColorScheme(.light)  // Preview in light mode
    }
}
