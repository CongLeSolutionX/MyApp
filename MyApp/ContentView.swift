//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var appDelegateData: String = "No data yet"
    @State private var viewAppeared = false // Track view appearance

    var body: some View {
        VStack {
            Text("Hello, World!")
            Text("Scene Phase: \(scenePhase)")
                .padding(.bottom)
            Text("AppDelegate Data: \(appDelegateData)")
        }
        .onAppear {
            guard !viewAppeared else { return } // Prevent redundant calls
            viewAppeared = true
            printLog("[ContentView] View.onAppear()")
            fetchAppDelegateData() // Encapsulate data fetching
        }
        .onDisappear {
            printLog("[ContentView] View.onDisappear()")
            viewAppeared = false // Reset flag
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            printLog("[ContentView] Scene Phase changed from \(oldPhase) to \(newPhase)")
            handleScenePhaseChange(newPhase) // Reuse scene phase change logic
        }
    }

    private func fetchAppDelegateData() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let data = appDelegate.appData {
            appDelegateData = data
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) { // Consistent scene phase handling
        switch phase {
        case .active:
            printLog("[ContentView] Scene became active from ContentView")
        case .inactive:
            printLog("[ContentView] Scene became inactive from ContentView")
        case .background:
            printLog("[ContentView] Scene entered background from ContentView")
        @unknown default:
            printLog("[ContentView] Unknown scene phase from ContentView")
        }
    }
}

// MARK: - Previews
#Preview {
    ContentView()
}
