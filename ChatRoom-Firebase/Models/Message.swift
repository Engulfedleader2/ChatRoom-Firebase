//
//  Message.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/8/24.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable, Equatable {
    @DocumentID var id: String? = UUID().uuidString
    let username: String
    let message: String
    let timestamp: Date
    let profileImageURL: String?  // URL for the user's profile image

    // Equatable conformance
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
               lhs.username == rhs.username &&
               lhs.message == rhs.message &&
               lhs.timestamp == rhs.timestamp
    }
}
