//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Document.self)
            
        }
    }
}
