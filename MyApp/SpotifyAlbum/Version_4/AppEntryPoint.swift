//
//  Untitled.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import SwiftUI

@main
struct MyApp: App { // Replace YourAppNameApp with your actual app name
    @StateObject private var audioPlayerManager = AudioPlayerManager() // Create instance

    var body: some Scene {
        WindowGroup {
            // Your root view (e.g., ContentView, or directly NavigationView wrapping AlbumDetailView)
            NavigationView { // Assuming NavigationView is your root
                 AlbumDetailView() // Or your initial view
            }
            .environmentObject(audioPlayerManager) // Inject into environment
        }
    }
}
