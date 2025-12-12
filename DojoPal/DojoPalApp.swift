//
//  DojoPalApp.swift
//  DojoPal
//
//  Created on iOS
//

import SwiftUI
import FirebaseCore

@main
struct DojoPalApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
