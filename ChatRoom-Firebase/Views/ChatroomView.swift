//
//  ChatroomView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/10/24.
//

import SwiftUI
import FirebaseDatabase

struct ChatroomView: View {
    
    @StateObject private var viewModel: ChatroomViewModel
    @State private var messageText: String = ""
    
    init(chatroomID: String) {
        _viewModel = StateObject(wrappedValue: ChatroomViewModel(chatroomID: chatroomID))
    }
    
    var body: some View {
        VStack{
            //This will show who is in the room
            HStack{
                Image(systemName: "person.fill")
                //Text("\(viewModel.users)")
            }
        }
    }
}


struct ChatroomView_Previews_Alternative: PreviewProvider {
    static var previews: some View {
        ChatroomView(chatroomID: "exampleChatroomID")
            .previewDevice("iPhone 14")
    }
}

