//
//  LoginView.swift
//  ChatRoom-Firebase
//
//  Created by Israel on 8/9/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var loginError: String?
    @State private var isLoggedIn = false // State variable to track login status
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // App Logo or Title
                Text("Chatroom app")
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
                
                // Password Field
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                
                // Login Button
                Button(action: {
                    isLoggingIn = true
                    signIn()
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
                .disabled(email.isEmpty || password.isEmpty)
                .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1.0)
                
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
                OLDChatroomView()
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
            if let error = error {
                self.loginError = error.localizedDescription
                print("Login failed: \(error.localizedDescription)")
            } else {
                print("User signed in successfully")
                isLoggedIn = true // Navigate to ChatroomView
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
