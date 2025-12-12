//
//  MainView.swift
//  DojoPal
//
//  Main screen after approval
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var userData: User?
    @State private var isLoading = true
    @State private var showStudents = false
    @State private var showAccountSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView()
                } else if let user = userData {
                    Text("Welcome to DojoPal!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Welcome, \(user.fullName)!")
                        .font(.title3)
                    
                    Text("Email: \(user.emailAddress)")
                        .foregroundColor(.secondary)
                    
                    Text("Club: \(user.clubName)")
                        .foregroundColor(.secondary)
                    
                    Button(action: { showStudents = true }) {
                        Text("Manage Students")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    
                    Button(action: { showAccountSettings = true }) {
                        Text("Account Settings")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                    
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("DojoPal")
            .navigationDestination(isPresented: $showStudents) {
                StudentsView()
            }
            .navigationDestination(isPresented: $showAccountSettings) {
                AccountSettingsView()
            }
            .onAppear {
                loadUserData()
            }
            .refreshable {
                loadUserData()
            }
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
}
