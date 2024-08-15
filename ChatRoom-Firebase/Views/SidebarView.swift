//
//  SidebarView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/11/24.
//

import SwiftUI

struct SidebarView: View {
    @Binding var isSidebarVisible: Bool
    @Binding var rooms: [String]
    @Binding var newRoomName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with Username and Sign Out
            HStack {
                Text("Welcome, Username!")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    // Sign out action
                }) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 10)
            .padding(.top, safeAreaInsets.top) // Ensure safe area is respected
            
            // Tabs for "Rooms" and "Users"
            VStack {
                HStack {
                    Button(action: {
                        // Action for "Rooms" tab
                    }) {
                        Text("Rooms")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity) // Ensure the button stretches
                    }
                    
                    Button(action: {
                        // Action for "Users" tab
                    }) {
                        Text("Users")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity) // Ensure the button stretches
                    }
                }
                .padding(.horizontal) // Add horizontal padding
            }
            
            // Available Rooms
            VStack(alignment: .leading, spacing: 10) {
                Text("Available Rooms")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.leading)
                
                ForEach(rooms, id: \.self) { room in
                    Button(action: {
                        // Action when the room is tapped
                        print("Room '\(room)' tapped")
                        // Navigate to the selected room's chat view
                    }) {
                        HStack {
                            Text(room)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure the button takes the full width
                        .contentShape(Rectangle()) // Make the entire area tappable
                    }
                    .buttonStyle(PlainButtonStyle()) // Removes the default button styling
                    .background(Color.clear) // Ensures the background stays clear
                    .swipeActions(edge: .trailing) { // Swipe from the right to delete
                        Button(role: .destructive) {
                            if let index = rooms.firstIndex(of: room) {
                                rooms.remove(at: index)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            .padding(.horizontal) // Add padding to the VStack to make sure it doesn't extend past the screen edges

            Spacer()
            
            // New Room Input and Button
            HStack {
                TextField("New room name", text: $newRoomName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                
                Button(action: {
                    if !newRoomName.isEmpty {
                        rooms.append(newRoomName)
                        newRoomName = ""
                    }
                }) {
                    Text("Create New Room")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal) // Add padding if needed
        }
        .padding()
        .frame(width: 300)
        .background(Color(red: 31/255, green: 41/255, blue: 55/255))
        .edgesIgnoringSafeArea(.all)
    }
    
    var safeAreaInsets: UIEdgeInsets {
        UIApplication.shared.windows.first?.safeAreaInsets ?? UIEdgeInsets()
    }
}

struct SidebarView_Previews: PreviewProvider {
    @State static var isSidebarVisible = true
    @State static var rooms = ["test", "test2", "Room3"]
    @State static var newRoomName = ""
    
    static var previews: some View {
        SidebarView(isSidebarVisible: $isSidebarVisible, rooms: $rooms, newRoomName: $newRoomName)
    }
}
