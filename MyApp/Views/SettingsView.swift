//
//  SettingsView.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsCoordinator = SettingsCoordinator()

    var body: some View {
        List {
            NavigationLink(destination: settingsCoordinator.showPrivacySettings()) {
                Text("Privacy Settings")
            }
            NavigationLink(destination: settingsCoordinator.showNotificationSettings()) {
                Text("Notification Settings")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
