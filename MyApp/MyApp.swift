//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

@main
struct MyApp: App {
    // Monitor the app's scene phase (active, inactive, background)
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Equivalent to application(_:didFinishLaunchingWithOptions:)
        print("[MyApp] App initialized (didFinishLaunchingWithOptions)")
        
        // Configure URLCache
        let memoryCapacity = 50 * 1024 * 1024 // 50 MB
        let diskCapacity = 200 * 1024 * 1024 // 200 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "webViewCache")
        URLCache.shared = cache
    }

    var body: some Scene {

        WindowGroup {
             UIKitViewControllerWrapper()
            // ContentView() // Option to switch to pure SwiftUI view
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            print("[MyApp] Scene phase changed from \(oldPhase) to \(newPhase)")
            switch newPhase {
            case .active:
                print("[MyApp] Scene became active from MyApp")
            case .inactive:
                print("[MyApp] Scene became inactive from MyApp")
            case .background:
                print("[MyApp] Scene entered background from MyApp")
            @unknown default:
                print("[MyApp] Unknown scene phase from MyApp")
            }
        }
    }
}
