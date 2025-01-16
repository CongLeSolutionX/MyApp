//
//  AppContentView.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI
struct AppContentView: View {
    @StateObject var appCoordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $appCoordinator.navigationPath) {
            Color.clear // An invisible, empty view as your temporary departure point
                .onAppear {
                    if appCoordinator.navigationPath.isEmpty {
                        appCoordinator.push(AppCoordinator.AppPage.home)
                    }
                }
                .navigationDestination(for: AppCoordinator.AppPage.self) { page in
                    switch page {
                    case .home:
                        HomeView()
                            .environmentObject(appCoordinator)
                    case .settings:
                        if let settingsCoordinator = appCoordinator.settingsCoordinator {
                            SettingsView()
                                .environmentObject(settingsCoordinator)
                        }
                    case .profile(let userID):
                        ProfileView(userID: userID)
                    case .productDetail(let product):
                        ProductDetailView(product: product)
                    }
                }
                .navigationDestination(for: SettingsCoordinator.SettingsPage.self) { page in
                    switch page {
                    case .main:
                        if let settingsCoordinator = appCoordinator.settingsCoordinator {
                            SettingsView()
                                .environmentObject(settingsCoordinator)
                        }
                    case .privacy:
                        PrivacySettingsView()
                    case .notifications:
                        NotificationSettingsView()
                    }
                }
        }
        .environmentObject(appCoordinator)
        .onOpenURL { url in
            appCoordinator.handleDeepLink(url)
        }
    }
}
