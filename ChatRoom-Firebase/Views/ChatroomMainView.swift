//
//  ChatroomMainView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/11/24.
//

import SwiftUI

struct ChatroomMainView: View {
    @State private var isSidebarVisible: Bool = false
    @State private var selectedRoom: String? = nil
    @State private var newRoomName: String = ""
    @State private var rooms: [String] = ["test", "test2"]
    
    var body: some View {
        ZStack {
            // Main Content Area
            VStack {
                HStack {
                    // Button to toggle sidebar
                    Button(action: {
                        withAnimation {
                            isSidebarVisible.toggle()
                        }
                    }) {
                        Image(systemName: "sidebar.leading")
                            .font(.largeTitle)
                            .padding()
                    }
                    Spacer()
                    
                    // Settings gear button
                    Button(action: {
                        // Open settings action
                    }) {
                        Image(systemName: "gearshape")
                            .font(.largeTitle)
                            .padding()
                    }
                }
                
                if selectedRoom == nil {
                    Text("Select a room to start chatting")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Chat content for the selected room
                    Text("Chat in room: \(selectedRoom!)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color.white)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 100 {
                            withAnimation {
                                isSidebarVisible = true
                            }
                        } else if value.translation.width < -100 {
                            withAnimation {
                                isSidebarVisible = false
                            }
                        }
                    }
            )
            
            // Sidebar - Positioned to the left edge
            HStack {
                SidebarView(isSidebarVisible: $isSidebarVisible, rooms: $rooms, newRoomName: $newRoomName)
                    .offset(x: isSidebarVisible ? 0 : -300) // Position off-screen when hidden
                    .transition(.move(edge: .leading))
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ChatroomMainView_Previews: PreviewProvider {
    static var previews: some View {
        ChatroomMainView()
    }
}
