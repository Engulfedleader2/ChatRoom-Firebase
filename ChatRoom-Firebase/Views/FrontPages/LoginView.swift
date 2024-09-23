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
    @State private var rememberMe = false  // Track if "Remember Me" is enabled
    @State private var isShowingPasswordResetAlert = false  // Track password reset alert
    
    @State private var showEmailNotVerifiedAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                HStack {
                    Image("logo-no-background")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 100)
                }
                Spacer()
                
                // Email Field
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("Email Address", text: $email)
                        .padding()
                        .foregroundColor(.red)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemGray5)))
                .shadow(radius: 2)
                .padding(.bottom, 20)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                
                // Password Field
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    SecureField("Password", text: $password)
                        .padding()
                        .foregroundColor(.white)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemGray5)))
                .shadow(radius: 2)
                .padding(.bottom, 5)
                
                // Forgot Password Link
                HStack {
                    Spacer()
                    Button(action: {
                        sendPasswordReset()
                    }) {
                        Text("Forgot my password?")
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                .padding(.bottom, 20)
                
                // "Remember Me" Toggle
                Toggle(isOn: $rememberMe) {
                    Text("Remember Me")
                        .foregroundColor(.white)
                }
                .padding(.bottom, 20)
                .padding(.trailing, 10)
                
                // Login Button
                Button(action: {
                    isLoggingIn = true
                    dismissKeyboard()
                    signIn()
                }) {
                    if isLoggingIn {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.2, green: 0.2, blue: 0.35))
                            .cornerRadius(10)
                    } else {
                        Text("Login")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.2, green: 0.2, blue: 0.35))
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
                        .foregroundColor(.white)
                    NavigationLink(destination: RegistrationView()) {
                        Text("Sign up")
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(
                Color(red: 0.1, green: 0.1, blue: 0.2)
                    .edgesIgnoringSafeArea(.all)
            )
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
            .alert(isPresented: $isShowingPasswordResetAlert) {
                Alert(
                    title: Text("Password Reset"),
                    message: Text("If an account with this email exists, a password reset link will be sent."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showEmailNotVerifiedAlert) {
                Alert(
                    title: Text("Email Not Verified"),
                    message: Text("Please verify your email before logging in."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                loadRememberedEmail()
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
                    saveRememberedEmail()  // Save email if "Remember Me" is enabled
                    
                    // Check if the email is verified
                    if user.isEmailVerified {
                        if user.displayName == nil {
                            let db = Firestore.firestore()
                            db.collection("users").document(user.uid).getDocument { document, error in
                                if let error = error {
                                    print("Error retrieving user data: \(error)")
                                    self.loginError = "Error retrieving user data."
                                } else if let document = document, document.exists {
                                    if let username = document.data()?["username"] as? String {
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
                    } else {
                        // Handle signOut call safely
                        do {
                            try Auth.auth().signOut()
                            showEmailNotVerifiedAlert = true // Show alert if not verified
                        } catch let signOutError as NSError {
                            print("Error signing out: \(signOutError.localizedDescription)")
                            loginError = "Error signing out. Please try again."
                        }
                    }
                }
            }
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Load remembered email from UserDefaults
    func loadRememberedEmail() {
        if let savedEmail = UserDefaults.standard.string(forKey: "rememberedEmail") {
            email = savedEmail
            rememberMe = true
        }
    }
    
    // Save email to UserDefaults if "Remember Me" is enabled
    func saveRememberedEmail() {
        if rememberMe {
            UserDefaults.standard.set(email, forKey: "rememberedEmail")
        } else {
            UserDefaults.standard.removeObject(forKey: "rememberedEmail")
        }
    }
    
    // Function to send password reset email
    func sendPasswordReset() {
        guard !email.isEmpty else {
            loginError = "Please enter your email address to reset the password."
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                loginError = error.localizedDescription
            } else {
                isShowingPasswordResetAlert = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}
