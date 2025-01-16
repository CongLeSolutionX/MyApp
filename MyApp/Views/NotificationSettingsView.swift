//
//  NotificationSettingsView.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI


struct NotificationSettingsView: View {
    var body: some View {
        VStack {
            Text("Notification Settings")
                .font(.largeTitle)
            // Notification settings content goes here
        }
        .padding()
        .navigationTitle("Notification Settings") // Add a title
        .navigationBarTitleDisplayMode(.inline)
    }
}
