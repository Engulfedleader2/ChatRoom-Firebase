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
                print("Error fetching chatrooms: \(error.localizedDescription)")
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
                
                let name = data["name"] as? String ?? doc.documentID
                
                let lastMessage: String
                let timestamp: Date
                
                if let messages = data["messages"] as? [[String: Any]] {
                    print("Messages array: \(messages)") // Debug statement
                    
                    let sortedMessages = messages.sorted {
                        let firstTimestamp = ($0["timestamp"] as? Timestamp)?.dateValue() ?? Date.distantPast
                        let secondTimestamp = ($1["timestamp"] as? Timestamp)?.dateValue() ?? Date.distantPast
                        return firstTimestamp < secondTimestamp
                    }
                    
                    if let latestMessage = sortedMessages.last {
                        print("Latest message: \(latestMessage)") // Debug statement
                        
                        lastMessage = latestMessage["message"] as? String ?? "No recent messages"
                        timestamp = (latestMessage["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    } else {
                        lastMessage = "No recent messages"
                        timestamp = Date()
                    }
                } else {
                    print("No messages array found in data.") // Debug statement
                    lastMessage = "No recent messages"
                    timestamp = Date()
                }
                
                fetchedChatrooms.append(Chatroom(id: doc.documentID, name: name, lastMessage: lastMessage, timestamp: timestamp))
            }
            
            // Sort by the most recent timestamp
            self.chatrooms = fetchedChatrooms.sorted(by: { $0.timestamp > $1.timestamp })
        }
    }

}
