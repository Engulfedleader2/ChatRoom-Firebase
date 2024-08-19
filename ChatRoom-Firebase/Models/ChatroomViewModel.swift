//
//  ChatroomViewModel.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/10/24.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class ChatroomViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage = ""
    
    private var db = Firestore.firestore()
    private var chatroomID: String
    
    init(chatroomID: String) {
        self.chatroomID = chatroomID
        fetchMessages()
    }
    
    func fetchMessages() {
        db.collection("chatrooms").document(chatroomID).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error fetching messages: \(error)")
                return
            }
            
            guard let document = documentSnapshot, let data = document.data() else {
                print("No messages found")
                return
            }
            
            // Map the Firestore data to Message structs
            self.messages = data.keys.compactMap { key in
                if key.starts(with: "message_"), let messageData = data[key] as? [String: Any] {
                    let id = key
                    let message = messageData["message"] as? String ?? "No message"
                    let username = messageData["username"] as? String ?? "Unknown"
                    let timestamp = (messageData["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    return Message(id: id, username: username, message: message, timestamp: timestamp)
                }
                return nil
            }.sorted(by: { $0.timestamp < $1.timestamp })
        }
    }

    func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Cannot send an empty message")
            return
        }
        
        let timestamp = Timestamp(date: Date())
        let messageID = "message_\(timestamp.seconds)"  // This maps the message field based on timestamp

        // Fetch username from Firestore
        if let user = Auth.auth().currentUser {
            let userDoc = db.collection("users").document(user.uid)
            userDoc.getDocument { document, error in
                if let error = error {
                    print("Error fetching username: \(error)")
                    return
                }
                
                let username = document?.data()?["username"] as? String ?? "Unknown"
                
                // Message data with field mapping
                let messageData: [String: Any] = [
                    "message": self.newMessage,
                    "username": username,
                    "timestamp": timestamp
                ]
                
                // Using the messageID as the key, similar to your web implementation
                self.db.collection("chatrooms").document(self.chatroomID).updateData([messageID: messageData]) { error in
                    if let error = error {
                        print("Error sending message: \(error)")
                    } else {
                        print("Message sent successfully")
                        self.newMessage = ""
                    }
                }
            }
        }
    }


}
