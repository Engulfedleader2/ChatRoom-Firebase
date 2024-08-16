//
//  LoginView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/9/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var loginError: String?
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // App Logo or Title
                Text("Chatroom App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                
                // Email Field
                TextField("Email Address", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                
                // Password Field
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                
                // Login Button
                Button(action: {
                    isLoggingIn = true
                    dismissKeyboard() // Dismiss keyboard
                    signIn()
                }) {
                    if isLoggingIn {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    } else {
                        Text("Login")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 20)
                .disabled(email.isEmpty || password.isEmpty || isLoggingIn)
                .opacity(email.isEmpty || password.isEmpty || isLoggingIn ? 0.5 : 1.0)
                
                Spacer()
                
                // Sign-up Link
                HStack {
                    Text("Don't have an account?")
                    NavigationLink(destination: RegistrationView()) {
                        Text("Sign up")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                ChatroomListView()
            }
            .navigationBarHidden(true)
            .alert(isPresented: Binding<Bool>(
                get: { loginError != nil },
                set: { if !$0 { loginError = nil } }
            )) {
                Alert(title: Text("Login Error"), message: Text(loginError ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoggingIn = false
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .invalidEmail:
                    loginError = "Invalid email address."
                case .wrongPassword:
                    loginError = "Incorrect password."
                case .userNotFound:
                    loginError = "No user found with this email."
                case .networkError:
                    loginError = "Network error. Please try again."
                default:
                    loginError = error.localizedDescription
                }
                print("Login failed: \(loginError ?? "")")
            } else {
                print("User signed in successfully")
                if let user = Auth.auth().currentUser {
                    // Check if display name is set
                    if user.displayName == nil {
                        // Retrieve username from Firestore
                        let db = Firestore.firestore()
                        db.collection("users").document(user.uid).getDocument { document, error in
                            if let error = error {
                                print("Error retrieving user data: \(error)")
                                self.loginError = "Error retrieving user data."
                            } else if let document = document, document.exists {
                                if let username = document.data()?["username"] as? String {
                                    // Set the display name to the retrieved username
                                    let changeRequest = user.createProfileChangeRequest()
                                    changeRequest.displayName = username
                                    changeRequest.commitChanges { error in
                                        if let error = error {
                                            print("Error setting display name: \(error)")
                                        } else {
                                            print("Display name set successfully to \(username)")
                                        }
                                    }
                                }
                            }
                            isLoggedIn = true
                        }
                    } else {
                        isLoggedIn = true
                    }
                }
            }
        }
    }

    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
