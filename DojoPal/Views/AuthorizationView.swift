//
//  AuthorizationView.swift
//  DojoPal
//
//  Authorization screen for sign-up gating
//

import SwiftUI

struct AuthorizationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var authorizationCode = ""
    @State private var codeError = ""
    @State private var isLoading = false
    @State private var showSignUp = false
    
    private let validCode = "WKC2006"
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("Authorization Required")
                .font(.title)
                .fontWeight(.bold)
            
            Text("To create an account, please enter the authorization code provided by your instructor.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("Authorization Code", text: $authorizationCode)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: authorizationCode) { _ in validateCode() }
                
                if !codeError.isEmpty {
                    Text(codeError)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            
            Button(action: proceedToSignUp) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Proceed to Sign Up")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || authorizationCode.isEmpty)
            .padding(.horizontal)
            
            Text("Don't have an authorization code? Contact your instructor.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Back to Sign In") {
                dismiss()
            }
            
            Spacer()
        }
        .navigationTitle("Authorization")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showSignUp) {
            SignUpView()
        }
    }
    
    private func validateCode() {
        codeError = authorizationCode.uppercased() == validCode.uppercased() ? "" : "Invalid authorization code"
    }
    
    private func proceedToSignUp() {
        guard authorizationCode.uppercased() == validCode.uppercased() else {
            codeError = "Invalid authorization code"
            return
        }
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            showSignUp = true
        }
    }
}
