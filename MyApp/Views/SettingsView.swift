//
//  SettingsView.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsCoordinator: SettingsCoordinator

    var body: some View {
        NavigationStack(path: $settingsCoordinator.navigationPath) {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.largeTitle)

                Button("Privacy Settings") {
                    settingsCoordinator.push(.privacy)
                }

                Button("Notification Settings") {
                    settingsCoordinator.push(.notifications)
                }
            }
            .padding()
            .navigationDestination(for: SettingsCoordinator.SettingsPage.self) { page in
                switch page {
                case .privacy:
                    PrivacySettingsView()
                case .notifications:
                    NotificationSettingsView()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
