//
//  Chatroomview.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/8/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct OLDChatroomView: View {
    @State private var message = ""
    @State private var messages: [ChatMessage] = []
    @State private var numberOfUsersOnline = 0
    @State private var username: String = ""

    
    var body: some View {
        VStack {
            // Header with online users count
            HStack {
                Text("Users Online: \(numberOfUsersOnline)")
                    .font(.headline)
                    .padding()
                
                Spacer()
            }
            .background(Color.gray.opacity(0.2))
            
            // Chat messages list
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages) { chatMessage in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chatMessage.text)
                                .font(.body)
                                .padding(.bottom, 2)
                            
                            HStack {
                                Spacer()
                                Text(chatMessage.sender)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                            
                            Divider()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Message input and send button
            HStack {
                TextField("Enter your message...", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title)
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            fetchMessages()
            fetchOnlineUsers()
            fetchUsername()
        }
        .navigationTitle("Chatroom")
    }
    
    private func fetchMessages() {
        let db = Firestore.firestore()
        db.collection("messages").order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.messages = documents.compactMap { queryDocumentSnapshot -> ChatMessage? in
                    return try? queryDocumentSnapshot.data(as: ChatMessage.self)
                }.reversed() // To show in chronological order
            }
    }
    private func fetchUsername() {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let uid = user.uid
        
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                self.username = document.data()?["username"] as? String ?? "Unknown User"
            } else {
                print("User document does not exist")
            }
        }
    }
    
    private func sendMessage() {
        guard !message.isEmpty else { return }
        
        let db = Firestore.firestore()
        let newMessage = ChatMessage(id: UUID().uuidString, sender: username, text: message, timestamp: Timestamp())
        
        db.collection("messages").addDocument(data: [
            "id": newMessage.id,
            "sender": newMessage.sender,
            "text": newMessage.text,
            "timestamp": newMessage.timestamp
        ]) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully")
                self.message = "" // Clear the input field
            }
        }
    }


    
    private func fetchOnlineUsers() {
        let db = Firestore.firestore()
        db.collection("users").whereField("isOnline", isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching online users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.numberOfUsersOnline = documents.count
            }
    }
}

// Message model
struct ChatMessage: Identifiable, Codable {
    var id: String
    var sender: String
    var text: String
    var timestamp: Timestamp
}

struct ChatroomView_Previews: PreviewProvider {
    static var previews: some View {
        OLDChatroomView()
    }
}
