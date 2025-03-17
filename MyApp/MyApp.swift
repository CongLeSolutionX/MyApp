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
//            ContentView()
            SynthwaveBackgroundView_V2 {
                Text("Synthwave")
                    .font(.custom("Pacifico-Regular", size: 48))
                    .foregroundColor(.yellow)
                    .overlay(
                                    Text("Synthwave")
                                        .font(.custom("Pacifico-Regular", size: 48))
                                        .foregroundColor(Color(red: 0.2, green: 1, blue: 0.8))
                                        .offset(x: 2, y: 2)  // Create an outline effect
                                )
            }
            .previewDevice("iPhone 14")
        }
    }
}
