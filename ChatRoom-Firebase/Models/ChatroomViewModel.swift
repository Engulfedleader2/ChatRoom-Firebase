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
import Network

class ChatroomViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage = ""
    @Published var isTyping = false  // To track if the user is typing
    @Published var otherUserTyping = ""  // To show who is typing
    @Published var numberOfUsersOnline: Int = 0  // To track the number of online users
    
    private var db = Firestore.firestore()
    private var chatroomID: String
    private var typingListener: ListenerRegistration?  // For listening to typing status
    private var messageListener: ListenerRegistration?  // For listening to messages
    private var onlineUsersListener: ListenerRegistration?  // For tracking online users
    private var typingTimer: Timer?  // Timer to manage typing status reset
    
    // Networking variables
    private var networkMonitor: NWPathMonitor = NWPathMonitor()
    @Published var isOffline: Bool = false

    init(chatroomID: String) {
        self.chatroomID = chatroomID
        fetchMessages()
        monitorTypingStatus()
        monitorNetworkStatus()
        fetchUsersOnline()  // Start fetching the number of online users
    }

    deinit {
        typingListener?.remove()
        messageListener?.remove()
        typingTimer?.invalidate()
        onlineUsersListener?.remove()  // Clean up the online users listener
    }

    // Fetch messages
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
                    let timestamp = (messageData["timestamp"] as? Timestamp)?.dateValue() ?? Date()

                    return Message(id: id, username: username, message: message, timestamp: timestamp)
                }
                return nil
            }.sorted(by: { $0.timestamp < $1.timestamp })
        }
    }

    // Monitor online users
    func fetchUsersOnline() {
        let usersRef = db.collection("chatrooms").document(chatroomID).collection("users")
        
        onlineUsersListener = usersRef.whereField("isOnline", isEqualTo: true).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("Error fetching online users: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Update the count of online users
            self.numberOfUsersOnline = documents.count
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

        if let user = Auth.auth().currentUser {
            let userDoc = db.collection("users").document(user.uid)
            userDoc.getDocument { document, error in
                if let error = error {
                    print("Error fetching user details: \(error)")
                    return
                }
                
                let username = document?.data()?["username"] as? String ?? "Unknown"
                
                // Message data
                let messageData: [String: Any] = [
                    "message": self.newMessage,
                    "username": username,
                    "timestamp": timestamp
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
            let typingStatus = isTyping ? "\(user.displayName ?? "Someone") is typing..." : ""
            db.collection("chatrooms").document(chatroomID).updateData([
                "typingStatus": typingStatus
            ])
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
            
            // Show the typing status from Firestore
            if let typingStatus = data["typingStatus"] as? String {
                self.otherUserTyping = typingStatus
            }
        }
    }

    // Trigger typing status when the user starts typing
    func startTyping() {
        if typingTimer?.isValid ?? false {
            typingTimer?.invalidate()
        }
        
        // Set isTyping and update Firestore with username is typing...
        updateTypingStatus(isTyping: true)
        
        // Throttle the typing indicator reset after 3 seconds of inactivity
        typingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            self.updateTypingStatus(isTyping: false)
        }
    }

    private func monitorNetworkStatus() {
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isOffline = path.status != .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }

    func updateOnlineStatus(isOnline: Bool) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let userRef = db.collection("chatrooms").document(chatroomID).collection("users").document(userID)
        
        userRef.setData([
            "isOnline": isOnline,
            "lastOnline": isOnline ? FieldValue.serverTimestamp() : Date()
        ], merge: true)
    }

}
