//
//  PendingApprovalView.swift
//  DojoPal
//
//  Pending approval screen with status checking
//

import SwiftUI
import FirebaseAuth

struct PendingApprovalView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var userData: User?
    @State private var isLoading = true
    @State private var isCheckingApproval = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("Account Pending Approval")
                .font(.title)
                .fontWeight(.bold)
            
            if let user = userData {
                Text("Hello \(user.fullName)!")
                    .font(.title3)
                
                Text("Your account is currently under review.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Text("Club: \(user.clubName)")
                    .foregroundColor(.secondary)
            }
            
            Text("We'll notify you once your account has been approved by an administrator. This usually takes 24-48 hours.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: checkApprovalStatus) {
                if isCheckingApproval {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Check Status")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isCheckingApproval)
            .padding(.horizontal)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Button("Sign Out") {
                authManager.signOut()
            }
            
            Spacer()
        }
        .navigationTitle("Pending Approval")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        FirestoreManager.shared.fetchUser(userId: userId) { user in
            self.userData = user
            self.isLoading = false
        }
    }
    
    private func checkApprovalStatus() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isCheckingApproval = true
        FirestoreManager.shared.fetchUser(userId: userId) { user in
            isCheckingApproval = false
            if let user = user, user.approved {
                // User is approved, will be redirected by ContentView
                self.userData = user
            } else {
                self.userData = user
            }
        }
    }
}
