//
//  SignUpView.swift
//  DojoPal
//
//  Sign up screen with comprehensive user details and validation
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var emailAddress = ""
    @State private var clubName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordVisible = false
    @State private var confirmPasswordVisible = false
    @State private var isLoading = false
    
    // Error states
    @State private var firstNameError = ""
    @State private var lastNameError = ""
    @State private var emailError = ""
    @State private var clubNameError = ""
    @State private var passwordError = ""
    @State private var confirmPasswordError = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showPendingApproval = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    // First Name
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: firstName) { _ in validateFirstName() }
                        
                        if !firstNameError.isEmpty {
                            Text(firstNameError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Last Name
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: lastName) { _ in validateLastName() }
                        
                        if !lastNameError.isEmpty {
                            Text(lastNameError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Email
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email Address", text: $emailAddress)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .onChange(of: emailAddress) { _ in validateEmail() }
                        
                        if !emailError.isEmpty {
                            Text(emailError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Club Name
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Club Name", text: $clubName)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: clubName) { _ in validateClubName() }
                        
                        if !clubNameError.isEmpty {
                            Text(clubNameError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Password
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
                        } else if !password.isEmpty {
                            Text(getPasswordStrengthMessage())
                                .font(.caption)
                                .foregroundColor(validatePasswordStrength() ? .green : .secondary)
                        }
                    }
                    
                    // Confirm Password
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            if confirmPasswordVisible {
                                TextField("Confirm Password", text: $confirmPassword)
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword)
                            }
                            
                            Button(action: { confirmPasswordVisible.toggle() }) {
                                Image(systemName: confirmPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: confirmPassword) { _ in validateConfirmPassword() }
                        
                        if !confirmPasswordError.isEmpty {
                            Text(confirmPasswordError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: signUp) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign Up")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading || !isFormValid)
                    
                    HStack {
                        Text("Already have an account?")
                        Button("Sign In") {
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showPendingApproval) {
            PendingApprovalView()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        firstNameError.isEmpty && lastNameError.isEmpty && emailError.isEmpty &&
        clubNameError.isEmpty && passwordError.isEmpty && confirmPasswordError.isEmpty &&
        !firstName.isEmpty && !lastName.isEmpty && !emailAddress.isEmpty &&
        !clubName.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
    
    private func validateFirstName() {
        firstNameError = firstName.isEmpty ? "First name is required" : ""
    }
    
    private func validateLastName() {
        lastNameError = lastName.isEmpty ? "Last name is required" : ""
    }
    
    private func validateEmail() {
        let emailRegex = "^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if emailAddress.isEmpty {
            emailError = "Email is required"
        } else if !predicate.evaluate(with: emailAddress) {
            emailError = "Please enter a valid email address"
        } else {
            emailError = ""
        }
    }
    
    private func validateClubName() {
        clubNameError = clubName.isEmpty ? "Club name is required" : ""
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordError = "Password is required"
        } else if !validatePasswordStrength() {
            passwordError = "Password must be strong (8+ chars, upper/lower case, digit, special char)"
        } else {
            passwordError = ""
        }
    }
    
    private func validatePasswordStrength() -> Bool {
        guard password.count >= 8 else { return false }
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        let specialChars = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        let hasSpecial = password.rangeOfCharacter(from: specialChars) != nil
        return hasUppercase && hasLowercase && hasDigit && hasSpecial
    }
    
    private func getPasswordStrengthMessage() -> String {
        guard !password.isEmpty else { return "" }
        var issues: [String] = []
        if password.count < 8 { issues.append("at least 8 characters") }
        if password.rangeOfCharacter(from: .uppercaseLetters) == nil { issues.append("one uppercase letter") }
        if password.rangeOfCharacter(from: .lowercaseLetters) == nil { issues.append("one lowercase letter") }
        if password.rangeOfCharacter(from: .decimalDigits) == nil { issues.append("one digit") }
        let specialChars = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        if password.rangeOfCharacter(from: specialChars) == nil { issues.append("one special character") }
        return issues.isEmpty ? "Strong password ✓" : "Password must contain: \(issues.joined(separator: ", "))"
    }
    
    private func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordError = "Please confirm your password"
        } else if password != confirmPassword {
            confirmPasswordError = "Passwords do not match"
        } else {
            confirmPasswordError = ""
        }
    }
    
    private func signUp() {
        guard isFormValid else { return }
        
        isLoading = true
        Auth.auth().createUser(withEmail: emailAddress, password: password) { result, error in
            if let error = error {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            } else if let user = result?.user {
                let newUser = User(
                    firstName: firstName.trimmingCharacters(in: .whitespaces),
                    lastName: lastName.trimmingCharacters(in: .whitespaces),
                    emailAddress: emailAddress.trimmingCharacters(in: .whitespaces),
                    clubName: clubName.trimmingCharacters(in: .whitespaces),
                    approved: false
                )
                
                FirestoreManager.shared.saveUser(newUser, userId: user.uid) { success in
                    isLoading = false
                    if success {
                        authManager.currentUser = user
                        showPendingApproval = true
                    } else {
                        errorMessage = "Failed to save user data"
                        showError = true
                    }
                }
            }
        }
    }
}
