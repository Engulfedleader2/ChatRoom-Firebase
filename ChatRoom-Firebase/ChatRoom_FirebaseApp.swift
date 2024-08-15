//
//  ChatRoom_FirebaseApp.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/8/24.
//

import SwiftUI
import Firebase

@main
struct ChatRoom_FirebaseApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ChatroomMainView()
        }
    }
}
