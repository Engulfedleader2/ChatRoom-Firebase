//
//  Message.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/8/24.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable{
    @DocumentID var id: String? = UUID().uuidString
     var username: String
     var text: String
     var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case text
        case timestamp
    }
}
