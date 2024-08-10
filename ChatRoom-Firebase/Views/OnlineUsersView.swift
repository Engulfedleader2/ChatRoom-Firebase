//
//  OnlineUsersView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/9/24.
//

import SwiftUI
import FirebaseFirestore

struct OnlineUsersView: View {
    @Binding var isOnlineListVisible: Bool
    @State private var onlineUsers: [User] = []
    @State private var numberOfUsersOnline = 0

    var body: some View {
        VStack {
            // Header showing the number of users online
            HStack {
                Image(systemName: "person.fill")
                Text("\(numberOfUsersOnline)")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isOnlineListVisible.toggle()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .background(Color.gray.opacity(0.2))
            
            // List of online users
            List(onlineUsers, id: \.id) { user in
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                    Text(user.username)
                        .padding(.leading, 5)
                }
            }
            .frame(width: 200) // Fixed width for the slide-out panel
            
            Spacer()
        }
        .background(Color.gray.opacity(0.2))
        .frame(width: isOnlineListVisible ? 200 : 0) // Adjust width based on visibility
        .offset(x: isOnlineListVisible ? 0 : 200) // Slide animation
        .onAppear {
            fetchOnlineUsers()
        }
    }
    
    private func fetchOnlineUsers() {
        let db = Firestore.firestore()
        db.collection("users").whereField("isOnline", isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching online users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                self.onlineUsers = documents.compactMap { queryDocumentSnapshot -> User? in
                    return try? queryDocumentSnapshot.data(as: User.self)
                }
                
                self.numberOfUsersOnline = self.onlineUsers.count
            }
    }
}

// User model
struct User: Identifiable, Codable {
    var id: String
    var username: String
}

struct OnlineUsersView_Previews: PreviewProvider {
    @State static var isOnlineListVisible = true
    
    static var previews: some View {
        OnlineUsersView(isOnlineListVisible: $isOnlineListVisible)
    }
}

