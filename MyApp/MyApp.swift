//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

@main
struct MyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Initialization

    init() {
        Self.configureURLCache() // Use static method for configuration
        printLog("[MyApp] App initialized (didFinishLaunchingWithOptions)")
    }

    var body: some Scene {
        WindowGroup {
            UIKitViewControllerWrapper()
             //ContentView() // Option to switch to pure SwiftUI view
        }
        .onChange(of: scenePhase, initial: true) { oldPhase, newPhase in // Include initial for first phase
            printLog("[MyApp] Scene phase changed from \(oldPhase) to \(newPhase)")
            handleScenePhaseChange(newPhase) // Extract phase change logic to a method
        }
    }

    // MARK: - Private Static Methods

    private static func configureURLCache() {
        let memoryCapacity = 50 * 1024 * 1024 // 50 MB
        let diskCapacity = 200 * 1024 * 1024 // 200 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "webViewCache")
        URLCache.shared = cache
    }

    // MARK: - Private Methods

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            printLog("[MyApp] Scene became active from MyApp")
        case .inactive:
            printLog("[MyApp] Scene became inactive from MyApp")
        case .background:
            printLog("[MyApp] Scene entered background from MyApp")
            // Perform background tasks if needed, e.g., save state
        @unknown default:
            printLog("[MyApp] Unknown scene phase from MyApp")
        }
    }
}

// Centralized logging function for consistency
func printLog(_ message: String) {
    print(message) // Can be expanded to more sophisticated logging
}
