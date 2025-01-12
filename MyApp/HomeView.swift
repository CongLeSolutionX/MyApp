//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 1/11/25.
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        VStack {
            Text("Home View")
            Button("Go to Settings") {
                coordinator.push(AppCoordinator.AppPage.settings)
            }
        }
        .navigationDestination(for: AppCoordinator.AppPage.self) { page in
            switch page {
            case .settings:
                SettingsView()
            case .profile:
                ProfileView()
            case .home:
                HomeView() // Technically, shouldn't push the same view
            }
        }
    }
}


struct SettingsView: View {
    var body: some View { Text("Settings View") }
}

struct ProfileView: View {
    var body: some View { Text("Profile View") }
}
