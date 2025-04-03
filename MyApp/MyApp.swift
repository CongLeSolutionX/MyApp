//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
//
//// Step 3: Embed in main app structure
//@main
//struct MyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

@main
struct HSRApp: App {
    // Ensure API key retrieval logic is robust
    private func getAPIKey() -> String {
        // Prioritize environment variable, fallback to a demo/default only for development
        if let key = ProcessInfo.processInfo.environment["FTC_API_KEY"], !key.isEmpty {
            return key
        } else {
            #if DEBUG
            print("Warning: Using DEMO_KEY. Set FTC_API_KEY environment variable for testing.")
            return "DEMO_KEY" // Use demo key only in debug builds if env var is missing
            #else
            print("Error: FTC_API_KEY environment variable not set in production build.")
            return "" // Return empty string in production if key is missing
            #endif
        }
    }

    private var ftcService: FTCService {
        FTCService(apiKey: getAPIKey())
    }

    var body: some Scene {
        WindowGroup {
            NoticesListView(viewModel: NoticesListViewModel(ftcService: ftcService))
        }
    }
}
