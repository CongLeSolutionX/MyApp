//
//  AppCoordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/11/25.
//

import SwiftUI


// MARK: - AppCoordinator
class AppCoordinator: ObservableObject {
    @Published var navigationPath: [AppRoute] = []

    func start() {
        navigationPath = []
    }

    func push(_ route: AppRoute) {
        navigationPath.append(route)
    }

    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func popToRoot() {
        navigationPath = []
    }

    // Navigation functions
    func showSettings() {
        push(.settings)
    }

    func showProfile(for userID: Int) {
        push(.profile(userID: userID))
    }

    func showProductDetail(for productID: Int) {
        let product = Product(id: productID, name: "Sample Product")
        push(.productDetail(product: product))
    }

    func showPrivacySettings() {
        push(.privacySettings)
    }

    func showNotificationSettings() {
        push(.notificationSettings)
    }
}
// MARK: - Extensions
extension AppCoordinator {
    func handleDeepLink(_ url: URL) {
        // Parse the URL and determine the destination
        if url.host == "product", let idString = url.pathComponents.last, let productID = Int(idString) {
            showProductDetail(for: productID)
        }
        // Handle other deep link cases
    }
}
