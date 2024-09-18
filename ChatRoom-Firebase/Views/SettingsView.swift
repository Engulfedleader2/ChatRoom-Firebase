//
//  SettingsView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 9/3/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var isDarkMode = false
    @State private var notificationsEnabled = true
    @State private var showingAlert = false
    @State private var showingDeleteAlert = false
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    @State private var shouldNavigateToLogin = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
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
                    Button(action: { showingDeleteAlert = true }) {
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
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteAccount()
                        },
                        secondaryButton: .cancel()
                    )
                }
                .onAppear(perform: loadUserData)
                
                // Navigation back to login screen
                NavigationLink(destination: LoginView(), isActive: $shouldNavigateToLogin) {
                    EmptyView()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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
            }
        }
    }
    
    // Sign out function
    private func signOut() {
        do {
            try Auth.auth().signOut()
            self.shouldNavigateToLogin = true  // Navigate back to login screen
        } catch let signOutError as NSError {
            self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            self.showingAlert = true
        }
    }
    
    // Delete account function
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Delete user data from Firestore
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).delete { error in
            if let error = error {
                self.errorMessage = "Error deleting user data: \(error.localizedDescription)"
                self.showingAlert = true
                return
            }
            
            // Delete Firebase Auth account
            user.delete { error in
                if let error = error {
                    self.errorMessage = "Error deleting account: \(error.localizedDescription)"
                    self.showingAlert = true
                } else {
                    print("Account deleted")
                    self.shouldNavigateToLogin = true  // Navigate back to login screen
                }
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
