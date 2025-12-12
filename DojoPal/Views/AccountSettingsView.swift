//
//  AccountSettingsView.swift
//  DojoPal
//
//  Account settings for editing email and password
//

import SwiftUI
import FirebaseAuth

struct AccountSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var newEmail = ""
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var currentPasswordVisible = false
    @State private var newPasswordVisible = false
    @State private var confirmPasswordVisible = false
    @State private var isLoading = false
    
    @State private var emailError = ""
    @State private var currentPasswordError = ""
    @State private var newPasswordError = ""
    @State private var confirmPasswordError = ""
    @State private var generalError = ""
    @State private var showError = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Email Address") {
                    TextField("Email Address", text: $newEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: newEmail) { _ in validateEmail() }
                    
                    if !emailError.isEmpty {
                        Text(emailError).foregroundColor(.red).font(.caption)
                    } else if newEmail != Auth.auth().currentUser?.email && !newEmail.isEmpty {
                        Text("Email will be updated").foregroundColor(.blue).font(.caption)
                    }
                }
                
                Section("Change Password") {
                    Text("Leave password fields empty if you don't want to change your password.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        if currentPasswordVisible {
                            TextField("Current Password", text: $currentPassword)
                        } else {
                            SecureField("Current Password", text: $currentPassword)
                        }
                        Button(action: { currentPasswordVisible.toggle() }) {
                            Image(systemName: currentPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .onChange(of: currentPassword) { _ in validateCurrentPassword() }
                    if !currentPasswordError.isEmpty {
                        Text(currentPasswordError).foregroundColor(.red).font(.caption)
                    }
                    
                    HStack {
                        if newPasswordVisible {
                            TextField("New Password", text: $newPassword)
                        } else {
                            SecureField("New Password", text: $newPassword)
                        }
                        Button(action: { newPasswordVisible.toggle() }) {
                            Image(systemName: newPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .onChange(of: newPassword) { _ in validateNewPassword() }
                    if !newPasswordError.isEmpty {
                        Text(newPasswordError).foregroundColor(.red).font(.caption)
                    } else if !newPassword.isEmpty {
                        Text(getPasswordStrengthMessage())
                            .font(.caption)
                            .foregroundColor(validatePasswordStrength() ? .green : .secondary)
                    }
                    
                    HStack {
                        if confirmPasswordVisible {
                            TextField("Confirm New Password", text: $confirmNewPassword)
                        } else {
                            SecureField("Confirm New Password", text: $confirmNewPassword)
                        }
                        Button(action: { confirmPasswordVisible.toggle() }) {
                            Image(systemName: confirmPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .onChange(of: confirmNewPassword) { _ in validateConfirmPassword() }
                    if !confirmPasswordError.isEmpty {
                        Text(confirmPasswordError).foregroundColor(.red).font(.caption)
                    }
                }
                
                if !generalError.isEmpty {
                    Section {
                        Text(generalError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: updateAccount) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoading || !hasChanges)
                }
            }
            .navigationTitle("Account Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                newEmail = Auth.auth().currentUser?.email ?? ""
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(generalError)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Account updated successfully!")
            }
        }
    }
    
    private var hasChanges: Bool {
        let emailChanged = newEmail != (Auth.auth().currentUser?.email ?? "")
        let passwordChanged = !newPassword.isEmpty
        return emailChanged || passwordChanged
    }
    
    private func validateEmail() {
        if newEmail == Auth.auth().currentUser?.email {
            emailError = ""
            return
        }
        
        let emailRegex = "^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if newEmail.isEmpty {
            emailError = "Email is required"
        } else if !predicate.evaluate(with: newEmail) {
            emailError = "Please enter a valid email address"
        } else {
            emailError = ""
        }
    }
    
    private func validateCurrentPassword() {
        if newPassword.isEmpty {
            currentPasswordError = ""
        } else if currentPassword.isEmpty {
            currentPasswordError = "Current password is required to change password"
        } else {
            currentPasswordError = ""
        }
    }
    
    private func validateNewPassword() {
        if newPassword.isEmpty {
            newPasswordError = ""
        } else if !validatePasswordStrength() {
            newPasswordError = "Password must be strong (8+ chars, upper/lower case, digit, special char)"
        } else {
            newPasswordError = ""
        }
    }
    
    private func validatePasswordStrength() -> Bool {
        guard newPassword.count >= 8 else { return false }
        let hasUppercase = newPassword.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = newPassword.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasDigit = newPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let specialChars = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        let hasSpecial = newPassword.rangeOfCharacter(from: specialChars) != nil
        return hasUppercase && hasLowercase && hasDigit && hasSpecial
    }
    
    private func getPasswordStrengthMessage() -> String {
        guard !newPassword.isEmpty else { return "" }
        var issues: [String] = []
        if newPassword.count < 8 { issues.append("at least 8 characters") }
        if newPassword.rangeOfCharacter(from: .uppercaseLetters) == nil { issues.append("one uppercase letter") }
        if newPassword.rangeOfCharacter(from: .lowercaseLetters) == nil { issues.append("one lowercase letter") }
        if newPassword.rangeOfCharacter(from: .decimalDigits) == nil { issues.append("one digit") }
        let specialChars = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        if newPassword.rangeOfCharacter(from: specialChars) == nil { issues.append("one special character") }
        return issues.isEmpty ? "Strong password ✓" : "Password must contain: \(issues.joined(separator: ", "))"
    }
    
    private func validateConfirmPassword() {
        if confirmNewPassword.isEmpty {
            confirmPasswordError = ""
        } else if newPassword != confirmNewPassword {
            confirmPasswordError = "Passwords do not match"
        } else {
            confirmPasswordError = ""
        }
    }
    
    private func updateAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        var updates: [String] = []
        isLoading = true
        generalError = ""
        
        // Update email if changed
        if newEmail != user.email {
            user.updateEmail(to: newEmail) { error in
                if let error = error {
                    self.generalError = error.localizedDescription
                    self.isLoading = false
                    self.showError = true
                } else {
                    updates.append("Email updated")
                    // Update Firestore
                    if let userId = Auth.auth().currentUser?.uid {
                        FirestoreManager.shared.fetchUser(userId: userId) { userData in
                            if var userData = userData {
                                userData.emailAddress = self.newEmail
                                FirestoreManager.shared.updateUser(userData, userId: userId) { _ in
                                    if !self.newPassword.isEmpty {
                                        self.updatePassword(updates: updates)
                                    } else {
                                        self.finishUpdate(updates: updates)
                                    }
                                }
                            } else if !self.newPassword.isEmpty {
                                self.updatePassword(updates: updates)
                            } else {
                                self.finishUpdate(updates: updates)
                            }
                        }
                    } else if !self.newPassword.isEmpty {
                        self.updatePassword(updates: updates)
                    } else {
                        self.finishUpdate(updates: updates)
                    }
                }
            }
        } else if !newPassword.isEmpty {
            updatePassword(updates: updates)
        } else {
            isLoading = false
            generalError = "No changes to save"
            showError = true
        }
    }
    
    private func updatePassword(updates: [String]) {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            generalError = "User not authenticated"
            isLoading = false
            showError = true
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                self.currentPasswordError = error.localizedDescription
                self.isLoading = false
            } else {
                user.updatePassword(to: self.newPassword) { error in
                    var newUpdates = updates
                    if error != nil {
                        self.generalError = error?.localizedDescription ?? "Failed to update password"
                        self.isLoading = false
                        self.showError = true
                    } else {
                        newUpdates.append("Password updated")
                        self.finishUpdate(updates: newUpdates)
                    }
                }
            }
        }
    }
    
    private func finishUpdate(updates: [String]) {
        isLoading = false
        showSuccess = true
    }
}
