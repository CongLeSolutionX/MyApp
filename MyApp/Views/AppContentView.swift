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
            HomeView()
                .environmentObject(appCoordinator)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .home:
                        HomeView()
                            .environmentObject(appCoordinator)
                    case .profile(let userID):
                        ProfileView(userID: userID)
                    case .productDetail(let product):
                        ProductDetailView(product: product)
                    case .settings:
                        SettingsView()
                            .environmentObject(appCoordinator)
                    case .privacySettings:
                        PrivacySettingsView()
                    case .notificationSettings:
                        NotificationSettingsView()
                    }
                }
        }
        .onOpenURL { url in
            appCoordinator.handleDeepLink(url)
        }
    }
}
