//
//  ContentView.swift
//  DojoPal
//
//  Main entry point that handles navigation based on auth state
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var isLoading = true
    @State private var userData: User?
    @State private var showSignIn = false
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if authManager.currentUser == nil || showSignIn {
                SignInView()
            } else if let user = userData {
                if !user.approved {
                    PendingApprovalView()
                } else {
                    MainView()
                }
            } else {
                SignInView()
            }
        }
        .onAppear {
            checkAuthState()
        }
        .onChange(of: authManager.currentUser) { newUser in
            if newUser == nil {
                showSignIn = true
            } else if let userId = newUser?.uid {
                loadUserData(userId: userId)
            }
        }
    }
    
    private func checkAuthState() {
        if let user = Auth.auth().currentUser {
            authManager.currentUser = user
            loadUserData(userId: user.uid)
        } else {
            isLoading = false
            showSignIn = true
        }
    }
    
    private func loadUserData(userId: String) {
        isLoading = true
        FirestoreManager.shared.fetchUser(userId: userId) { user in
            self.userData = user
            self.isLoading = false
            
            // Check approval status
            if let user = user, !user.approved {
                // Will show PendingApprovalView
            }
        }
    }
}
