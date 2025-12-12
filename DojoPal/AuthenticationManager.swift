//
//  AuthenticationManager.swift
//  DojoPal
//
//  Manages authentication state
//

import Foundation
import FirebaseAuth
import Combine

class AuthenticationManager: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    
    init() {
        currentUser = Auth.auth().currentUser
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        currentUser = nil
    }
}
