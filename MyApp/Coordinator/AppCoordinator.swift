//
//  AppCoordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/11/25.
//

import SwiftUI


// MARK: - AppCoordinator
class AppCoordinator: ObservableObject {
    @Published var navigationPath: [AppPage] = []
    @Published var settingsCoordinator: SettingsCoordinator?

    enum AppPage: Hashable {
        case home
        case settings
        case profile(userID: Int)
        case productDetail(product: Product)
    }

    func start() {
        push(.home)
    }

    func push(_ page: AppPage) {
        navigationPath.append(page)
    }

    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func popToRoot() {
        navigationPath = []
    }

    func showSettings() {
        settingsCoordinator = SettingsCoordinator()
        push(.settings)
    }

    func showProfile(for userID: Int) {
        push(.profile(userID: userID))
    }

    func showProductDetail(for productID: Int) {
        let product = Product(id: productID, name: "Sample Product")
        push(.productDetail(product: product))
    }
}
// MARK: - Extensions
extension AppCoordinator {
    func handleDeepLink(_ url: URL) {
        // Parse the URL and determine the destination
        // For example, if the URL is myapp://product/101
        if url.host == "product", let idString = url.pathComponents.last, let productID = Int(idString) {
            showProductDetail(for: productID)
        }
        // Handle other deep link cases
    }
}
