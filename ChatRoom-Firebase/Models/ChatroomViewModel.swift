//
//  ChatroomViewModel.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/10/24.
//

import FirebaseDatabase

class ChatroomViewModel: ObservableObject{
    private var dbRef: DatabaseReference!
    
    @Published var messages: [Message] = []
    
    init(chatroomID: String){
        dbRef = Database.database().reference().child("chatrooms/\(chatroomID)/messages")
        observeMessages()
    }
    func observeMessages(){
        dbRef.observe(.childAdded) { snapshot in
            if let data = snapshot.value as? [String: Any],
               let username = data["username"] as? String,
               let message = data["message"] as? String,
               let timestamp = data["timestamp"] as? String {
                let newMessage = Message(username: username, message: message, timestamp: timestamp)
                self.messages.append(newMessage)
            }
        }
    }
    func sendMessage(_ message: String, username: String) {
        let newMessageRef = dbRef.childByAutoId()
        let messageData: [String: Any] = [
            "username": username,
            "message": message,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        newMessageRef.setValue(messageData)
    }

    
    struct Message {
        let username: String
        let message: String
        let timestamp: String
    }
}
