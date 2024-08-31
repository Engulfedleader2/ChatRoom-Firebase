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
                print("Fetched document ID: \(doc.documentID), data: \(data)") // Debug statement
                
                // Use the document ID as the chatroom name
                let chatroom = Chatroom(id: doc.documentID, data: data)
                fetchedChatrooms.append(chatroom)
            }
            
            // Sort by the most recent timestamp
            self.chatrooms = fetchedChatrooms.sorted(by: { $0.timestamp > $1.timestamp })
            
            // Debug output to ensure the chatrooms are sorted correctly
            for chatroom in self.chatrooms {
                print("Chatroom: \(chatroom.name), Last Message: \(chatroom.lastMessage), Timestamp: \(chatroom.timestamp)")
            }
        }
    }
}
