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
    @Published var isTyping = false  // To track if the user is typing
    @Published var otherUserTyping = false  // To track if other users are typing
    
    private var db = Firestore.firestore()
    private var chatroomID: String
    private var typingListener: ListenerRegistration?  // For listening to typing status
    private var messageListener: ListenerRegistration?  // For listening to messages
    private var typingTimer: Timer?  // Timer to manage typing status reset
    
    init(chatroomID: String) {
        self.chatroomID = chatroomID
        fetchMessages()
        monitorTypingStatus()
    }
    
    deinit {
        typingListener?.remove()
        messageListener?.remove()
        typingTimer?.invalidate()
    }
    
    func fetchMessages() {
        messageListener = db.collection("chatrooms").document(chatroomID).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error fetching messages: \(error)")
                return
            }
            
            guard let document = documentSnapshot, let data = document.data() else {
                print("No messages found")
                return
            }
            
            self.messages = data.keys.compactMap { key in
                if key.starts(with: "message_"), let messageData = data[key] as? [String: Any] {
                    let id = key
                    let message = messageData["message"] as? String ?? "No message"
                    let username = messageData["username"] as? String ?? "Unknown"
                    let profileImageURL = messageData["profileImageURL"] as? String  // Handle profile image URL
                    let timestamp = (messageData["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    
                    return Message(id: id, username: username, message: message, timestamp: timestamp, profileImageURL: profileImageURL)
                }
                return nil
            }.sorted(by: { $0.timestamp < $1.timestamp })
        }
    }
    
    // Send a new message to Firestore
    func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Cannot send an empty message")
            return
        }
        
        let timestamp = Timestamp(date: Date())
        let messageID = "message_\(timestamp.seconds)"  // Unique message ID based on timestamp

        // Fetch username and profile image URL from Firestore
        if let user = Auth.auth().currentUser {
            let userDoc = db.collection("users").document(user.uid)
            userDoc.getDocument { document, error in
                if let error = error {
                    print("Error fetching user details: \(error)")
                    return
                }
                
                let username = document?.data()?["username"] as? String ?? "Unknown"
                let profileImageURL = document?.data()?["profileImageURL"] as? String ?? nil // Get the profile image URL
                
                // Message data
                let messageData: [String: Any] = [
                    "message": self.newMessage,
                    "username": username,
                    "timestamp": timestamp,
                    "profileImageURL": profileImageURL ?? ""  // Add profile image URL to message data
                ]
                
                // Using the messageID as the key
                self.db.collection("chatrooms").document(self.chatroomID).updateData([messageID: messageData]) { error in
                    if let error = error {
                        print("Error sending message: \(error)")
                    } else {
                        print("Message sent successfully")
                        self.newMessage = ""
                        self.updateTypingStatus(isTyping: false)  // Reset typing status after sending the message
                    }
                }
            }
        }
    }
    
    // Update typing status to Firestore
    func updateTypingStatus(isTyping: Bool) {
        self.isTyping = isTyping
        // Update typing status in Firestore for this user
        if let user = Auth.auth().currentUser {
            let typingStatusData: [String: Any] = [
                "isTyping": isTyping,
                "userID": user.uid
            ]
            db.collection("chatrooms").document(chatroomID).setData(typingStatusData, merge: true)
        }
    }
    
    // Monitor typing status of other users
    func monitorTypingStatus() {
        typingListener = db.collection("chatrooms").document(chatroomID).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error monitoring typing status: \(error)")
                return
            }
            
            guard let document = documentSnapshot, let data = document.data() else { return }
            
            if let isTyping = data["isTyping"] as? Bool, let userID = data["userID"] as? String {
                // Ensure that we are not setting typing status for the current user
                if let currentUser = Auth.auth().currentUser, currentUser.uid != userID {
                    self.otherUserTyping = isTyping
                }
            }
        }
    }
    
    // Trigger typing status when the user starts typing
    func startTyping() {
        if typingTimer?.isValid ?? false {
            typingTimer?.invalidate()
        }
        updateTypingStatus(isTyping: true)
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.updateTypingStatus(isTyping: false)
        }
    }
}
