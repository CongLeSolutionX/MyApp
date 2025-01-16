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
                .navigationDestination(for: AppCoordinator.AppPage.self) { page in
                    switch page {
                    case .home:
                        HomeView()
                            .environmentObject(appCoordinator)
                    case .settings:
                        if let settingsCoordinator = appCoordinator.settingsCoordinator {
                            SettingsView()
                                .environmentObject(settingsCoordinator)
                        } else {
                            Text("Settings not available")
                        }
                    case .profile(let userID):
                        ProfileView(userID: userID)
                    case .productDetail(let product):
                        ProductDetailView(product: product)
                    }
                }
        }
        .onOpenURL { url in
            appCoordinator.handleDeepLink(url)
        }
    }
}
