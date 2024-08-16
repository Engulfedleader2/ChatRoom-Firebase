//
//  ChatroomListViewModel.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/16/24.
//

import FirebaseFirestore
import SwiftUI

class ChatroomListViewModel: ObservableObject {
    @Published var chatrooms: [Chatroom] = []
    @Published var errorMessage: String? = nil
    
    private var db = Firestore.firestore()
    
    init() {
        fetchChatrooms()
    }
    
    func fetchChatrooms() {
        db.collection("chatrooms").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching chatrooms: \(error)")
                self.errorMessage = "Failed to fetch chatrooms."
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No chatrooms found")
                self.errorMessage = "No chatrooms available."
                return
            }
            
            var fetchedChatrooms: [Chatroom] = []
            
            for doc in documents {
                let data = doc.data()
                print("Fetched document data: \(data)") // Debug statement
                
                let lastMessage: String
                let timestamp: Date
                
                if let lastMessageData = data["messages"] as? [String: Any],
                   let lastMessageKey = lastMessageData.keys.sorted().last,
                   let messageData = lastMessageData[lastMessageKey] as? [String: Any] {
                    lastMessage = messageData["message"] as? String ?? "No recent messages"
                    timestamp = (messageData["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                } else {
                    lastMessage = "No recent messages"
                    timestamp = Date()
                }
                
                fetchedChatrooms.append(Chatroom(id: doc.documentID, name: doc.documentID, lastMessage: lastMessage, timestamp: timestamp))
            }
            
            self.chatrooms = fetchedChatrooms.sorted(by: { $0.timestamp > $1.timestamp })
        }
    }

}
