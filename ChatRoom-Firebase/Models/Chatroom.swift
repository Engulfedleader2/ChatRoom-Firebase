//
//  Chatroom.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/16/24.
//

import Foundation
import FirebaseFirestore

struct Chatroom: Identifiable {
    let id: String
    let name: String
    let lastMessage: String
    let timestamp: Date

    // Use the document ID as the chatroom name
    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = id  // Set the chatroom name to the document ID
        
        // Extract messages from fields starting with "message_"
        let messageFields = data.filter { $0.key.starts(with: "message_") }
        let messages = messageFields.compactMap { $0.value as? [String: Any] }
        
        if let latestMessage = messages.sorted(by: {
            let firstTimestamp = ($0["timestamp"] as? Timestamp)?.dateValue() ?? Date.distantPast
            let secondTimestamp = ($1["timestamp"] as? Timestamp)?.dateValue() ?? Date.distantPast
            return firstTimestamp < secondTimestamp
        }).last {
            self.lastMessage = latestMessage["message"] as? String ?? "No recent messages"
            self.timestamp = (latestMessage["timestamp"] as? Timestamp)?.dateValue() ?? Date.distantPast
        } else {
            self.lastMessage = "No recent messages"
            self.timestamp = Date.distantPast
        }
    }
}
