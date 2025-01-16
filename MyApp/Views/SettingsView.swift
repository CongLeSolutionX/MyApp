//
//  SettingsView.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI


struct SettingsView: View {
    @EnvironmentObject var settingsCoordinator: SettingsCoordinator // Now using SettingsCoordinator

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)

            Button("Privacy Settings") {
                settingsCoordinator.push(SettingsCoordinator.SettingsPage.privacy)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Notification Settings") {
                settingsCoordinator.push(SettingsCoordinator.SettingsPage.notifications)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .navigationTitle("Settings") // Add a title for SettingsView
        .navigationBarTitleDisplayMode(.inline)
    }
}

