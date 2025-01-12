//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

@main
struct CustomCoordinatorApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            AppContentView()
                .environmentObject(appCoordinator)
        }
    }
}
