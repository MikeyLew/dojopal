//
//  SignInView.swift
//  DojoPal
//
//  Sign in screen with email and password validation
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var passwordVisible = false
    @State private var isLoading = false
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showAuthorization = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .onChange(of: email) { _ in validateEmail() }
                        
                        if !emailError.isEmpty {
                            Text(emailError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            if passwordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            
                            Button(action: { passwordVisible.toggle() }) {
                                Image(systemName: passwordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: password) { _ in validatePassword() }
                        
                        if !passwordError.isEmpty {
                            Text(passwordError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: signIn) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading || !isFormValid)
                    
                    HStack {
                        Text("Don't have an account?")
                        Button("Sign Up") {
                            showAuthorization = true
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationDestination(isPresented: $showAuthorization) {
                AuthorizationView()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && emailError.isEmpty && passwordError.isEmpty
    }
    
    private func validateEmail() {
        let emailRegex = "^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        emailError = predicate.evaluate(with: email) ? "" : "Please enter a valid email address"
    }
    
    private func validatePassword() {
        passwordError = password.isEmpty ? "Password is required" : ""
    }
    
    private func signIn() {
        guard isFormValid else { return }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else if let user = result?.user {
                authManager.currentUser = user
            }
        }
    }
}
