//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

// Use in SwiftUI view
struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase // Observe scene phase

    // Example of data passed from AppDelegate/SceneDelegate (optional)
    @State private var appDelegateData: String = "No data yet"

    var body: some View {
        VStack {
            Text("Hello, World!")
            Text("Scene Phase: \(scenePhase)") // Display scene phase
                .padding(.bottom)
            Text("AppDelegate Data: \(appDelegateData)") // Display AppDelegate Data
        }
        .onAppear {
            print("[ContentView] View.onAppear()") // Lifecycle log
            // Example: Fetch data when view appears (can be triggered or updated from AppDelegate/SceneDelegate)
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let data = appDelegate.appData {
                appDelegateData = data
            }
        }
        .onDisappear {
            print("[ContentView] View.onDisappear()") // Lifecycle log
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            print("[ContentView] Scene Phase changed from \(oldPhase) to \(newPhase)") // Lifecycle log
            switch newPhase {
            case .active:
                print("[ContentView] Scene became active from ContentView")
            case .inactive:
                print("[ContentView] Scene became inactive from ContentView")
            case .background:
                print("[ContentView] Scene entered background from ContentView")
            @unknown default:
                print("[ContentView] Unknown scene phase from ContentView")
            }
        }
    }
}

// MARK: - Previews
// After iOS 17, we can use this syntax for preview:
#Preview {
    ContentView()
}

// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}
