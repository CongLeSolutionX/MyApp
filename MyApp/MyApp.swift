//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

// Step 3: Embed in main app structure
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            GoogleAIModeIntroView()
                .preferredColorScheme(.dark)
        }
    }
}
