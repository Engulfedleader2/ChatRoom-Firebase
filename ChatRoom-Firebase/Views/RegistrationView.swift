//
//  RegistrationView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/8/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegistrationView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var errorMessage = ""
    @State private var showingAlert = false
    @State private var showingConfirmation = false
    @State private var isRegistered = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Username Field
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Email Field
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Password Field
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // Register Button
                Button(action: register) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.isEmpty || password.isEmpty || username.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(email.isEmpty || password.isEmpty || username.isEmpty)
                
                Spacer()
                
                NavigationLink("", destination: ChatroomListView(), isActive: $isRegistered)
                    .hidden()
            }
            .navigationTitle("Sign Up")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Registration Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text("Registration Successful"),
                    message: Text("You have been successfully registered."),
                    dismissButton: .default(Text("OK"), action: {
                        isRegistered = true
                    })
                )
            }
        }
    }
    
    private func register() {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "Please fill in all fields."
            showingAlert = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "Registration error: \(error.localizedDescription)"
                self.showingAlert = true
                print("Registration error: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else {
                self.errorMessage = "Failed to get user."
                self.showingAlert = true
                return
            }
            
            self.saveUserProfile(user: user)
        }
    }
    
    private func saveUserProfile(user: FirebaseAuth.User) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = username // Set the display name to the entered username
        changeRequest.commitChanges { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showingAlert = true
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "username": username,
                "email": email,
            ]) { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showingAlert = true
                    return
                }

                print("User registered successfully with display name!")
                self.showingConfirmation = true
            }
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
