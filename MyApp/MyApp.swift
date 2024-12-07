//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

// Step 3: Embed in main app structure
@main
struct MyAppApp: App {
    var body: some Scene {
        WindowGroup {
            //SwiftUIContentView()
            //TikTikHomeView()
            //CapturingCameraView()
            PhotoPickerExampleView()
//            if #available(iOS 18.0, *) {
//                SelfieScoresAndLandmarksMainView()
//            } else {
//                // Fallback on earlier versions
//            }
        }
    }
}
