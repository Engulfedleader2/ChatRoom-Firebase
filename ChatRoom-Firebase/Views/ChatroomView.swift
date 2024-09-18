//
//  ChatroomView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/10/24.
//

import SwiftUI

struct ChatroomView: View {
    @StateObject private var viewModel: ChatroomViewModel
    @State private var showTimestampForMessageID: String? = nil
    @State private var numberOfUsersOnline: Int = 0
    @State private var typingTimer: Timer? // Timer to track typing status

    init(chatroomID: String) {
        _viewModel = StateObject(wrappedValue: ChatroomViewModel(chatroomID: chatroomID))
    }

    var body: some View {
        VStack {
            // Show offline status
            if viewModel.isOffline {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    Text("You are offline")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.orange)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding([.horizontal, .top])
                .transition(.opacity) // Animate appearance/disappearance
            }

            // Top view to show the number of users online
            HStack {
                Text("Users online: \(viewModel.numberOfUsersOnline)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color(red: 0.1, green: 0.1, blue: 0.2))

            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            messageRow(message: message)
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
                .onTapGesture {
                    dismissKeyboard()
                }
            }

            // Show typing indicator if another user is typing
            if !viewModel.otherUserTyping.isEmpty {
                HStack {
                    Text(viewModel.otherUserTyping)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal)
            }

            // Message Input
            messageInputBar()
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.2))
        .navigationTitle("Chatroom")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
          //  fetchUsersOnline()
            viewModel.monitorTypingStatus()
        }
    }

    // Break the message row UI into a separate view to simplify the main body
    @ViewBuilder
    private func messageRow(message: Message) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                // Username and message
                Text(message.username)
                    .font(.footnote)
                    .foregroundColor(.gray)

                HStack {
                    Text(message.message)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)

                    Spacer()

                    // Conditionally show the timestamp when swiped right
                    if showTimestampForMessageID == message.id {
                        Text("\(message.timestamp, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .transition(.move(edge: .trailing))
                    }
                }
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            withAnimation {
                                showTimestampForMessageID = message.id
                            }
                        } else {
                            withAnimation {
                                showTimestampForMessageID = nil
                            }
                        }
                    }
            )
        }
        .padding(.horizontal)
    }

    // Break the message input bar into its own function
    @ViewBuilder
    private func messageInputBar() -> some View {
        HStack {
            TextField("Type your message...", text: $viewModel.newMessage, onEditingChanged: { isEditing in
                if isEditing {
                    startTyping()
                }
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(10)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .frame(minHeight: 30)
                .onChange(of: viewModel.newMessage) { _ in
                    startTyping()
                }

            Button(action: {
                viewModel.sendMessage()
                showTimestampForMessageID = nil
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

    // Date formatter for displaying date and time
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

//    // Simulated function to fetch the number of users online in the chatroom
//    private func fetchUsersOnline() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.numberOfUsersOnline = Int.random(in: 1...50)
//        }
//    }

    // Function to dismiss the keyboard
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // Function to handle typing indicator
    private func startTyping() {
        // Invalidate the previous timer if any
        typingTimer?.invalidate()
        viewModel.startTyping() // Trigger typing status in ViewModel

        // Start a new timer to reset the typing indicator after 3 seconds of inactivity
        typingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            viewModel.updateTypingStatus(isTyping: false)
        }
    }
}

struct ChatroomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatroomView(chatroomID: "Room 1")
            .preferredColorScheme(.dark)
    }
}
