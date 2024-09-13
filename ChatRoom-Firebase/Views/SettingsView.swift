//
//  SettingsView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 9/3/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct SettingsView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var isDarkMode = false
    @State private var notificationsEnabled = true
    @State private var profileImage: UIImage? = nil
    @State private var imagePickerPresented = false
    @State private var errorMessage: String?
    @State private var showingAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Image Section
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                        .padding(.bottom, 20)
                } else {
                    Button(action: {
                        imagePickerPresented = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                    }
                }
                
                // Edit Profile Picture
                Button(action: {
                    imagePickerPresented = true
                }) {
                    Text("Change Profile Picture")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                // Username and Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.headline)
                    TextField("Enter your username", text: $username)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    Text("Email")
                        .font(.headline)
                    Text(email)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding(.vertical)
                
                // Bio Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(.headline)
                    TextField("Tell us something about yourself", text: $bio)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding(.vertical)
                
                // Notifications Toggle
                Toggle(isOn: $notificationsEnabled) {
                    Text("Enable Notifications")
                        .font(.headline)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                
                // Theme Toggle
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode")
                        .font(.headline)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                
                // Account Actions
                Button(action: signOut) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Account Deletion
                Button(action: deleteAccount) {
                    Text("Delete Account")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding()
            .dismissKeyboardOnTap()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadUserData)
        .sheet(isPresented: $imagePickerPresented) {
            ImagePicker(image: $profileImage)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
        .onChange(of: profileImage) { newImage in
            if let newImage = newImage {
                uploadProfileImage(newImage)
            }
        }
    }
    
    // Load user data from Firestore
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user found."
            showingAlert = true
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { document, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showingAlert = true
            } else if let document = document, document.exists {
                self.username = document.data()?["username"] as? String ?? "Unknown"
                self.email = user.email ?? "No email available"
                self.bio = document.data()?["bio"] as? String ?? ""
                
                if let profileImageUrl = document.data()?["profileImageUrl"] as? String, !profileImageUrl.isEmpty {
                    loadProfileImage(from: profileImageUrl)
                }
            }
        }
    }
    
    // Sign out function
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            self.showingAlert = true
        }
    }
    
    // Delete account function
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        user.delete { error in
            if let error = error {
                self.errorMessage = "Error deleting account: \(error.localizedDescription)"
                self.showingAlert = true
            } else {
                print("Account deleted")
            }
        }
    }
    
    // Function to upload a new profile image
    private func uploadProfileImage(_ image: UIImage) {
        guard let user = Auth.auth().currentUser else { return }
        
        // Use ProfileImageManager to upload the image
        ProfileImageManager.shared.uploadProfileImage(image, for: user.uid) { result in
            switch result {
            case .success(let profileImageUrl):
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).updateData(["profileImageUrl": profileImageUrl]) { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showingAlert = true
                    } else {
                        print("Profile image URL updated successfully.")
                    }
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }

    // Function to load the profile image
    private func loadProfileImage(from urlString: String) {
        ProfileImageManager.shared.loadProfileImage(from: urlString) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }

}
extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
