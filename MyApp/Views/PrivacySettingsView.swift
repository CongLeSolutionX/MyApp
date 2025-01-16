//
//  PrivacySettingsView.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI


struct PrivacySettingsView: View {
    var body: some View {
        VStack {
            Text("Privacy Settings")
                .font(.largeTitle)
            // Privacy settings content goes here
        }
        .padding()
        .navigationTitle("Privacy Settings") // Add a title
        .navigationBarTitleDisplayMode(.inline)
    }
}
