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
        dbRef.observe(.childAdded){ snapshot in
            if let data = snapshot
        }
    }
}
