//
//  ChatRoom_FirebaseApp.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/8/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct ChatRoom_FirebaseApp: App {
    init(){
        FirebaseApp.configure()
        
        // Enable Firestore offline persistence
        let settings = Firestore.firestore().settings
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
    }
    
    var body: some Scene {
        WindowGroup {
            if Auth.auth().currentUser != nil {
                ChatroomListView()
            } else {
                // Show login view
                LoginView()
            }
        }
    }
}
