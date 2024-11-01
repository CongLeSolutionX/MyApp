//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

// MARK: - Main Application
@main
struct LifecycleDemoApp: App {
    // Register AppDelegate (Objective-C)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            //MainSwiftUIViewWithObjCInstance()
            MainSwiftUIView()
        }
    }
}
