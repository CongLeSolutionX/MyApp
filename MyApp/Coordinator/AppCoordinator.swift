//
//  AppCoordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/11/25.
//

import SwiftUI


// MARK: - AppCoordinator
class AppCoordinator: ObservableObject, Coordinator {
    @Published var navigationPath: [AnyHashable] = []
    @Published var settingsCoordinator: SettingsCoordinator?
    
    var navigationBinding: Binding<[AnyHashable]> {
        Binding(
            get: { self.navigationPath },
            set: { self.navigationPath = $0 }
        )
    }
    
    func start() {
        push(AppPage.home)
    }
    
    func push<T: Hashable>(_ page: T) {
        navigationPath.append(page)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        navigationPath = []
    }
    
    enum AppPage: Hashable {
        case home
        case settings
        case profile(userID: Int)
        case productDetail(product: Product)
    }
    
    func showSettings() {
        settingsCoordinator = SettingsCoordinator(navigationPath: navigationBinding)
        settingsCoordinator?.start()
    }
    
    func showProfile(for userID: Int) {
        push(AppPage.profile(userID: userID))
    }
    
    func showProductDetail(for productID: Int) {
        let product = Product(id: productID, name: "Sample Product")
        push(AppPage.productDetail(product: product))
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

//class AppCoordinator: ObservableObject, Coordinator {
//    @Published var navigationPath = NavigationPath()
//    @Published var settingsCoordinator: SettingsCoordinator?
//
//    // Computed property to provide a Binding to navigationPath
//    var navigationBinding: Binding<NavigationPath> {
//        Binding(
//            get: { self.navigationPath },
//            set: { self.navigationPath = $0 }
//        )
//    }
//
//    func start() {
//        // Start with the Home page
//        push(AppPage.home)
//    }
//
//    func push<T: Hashable>(_ page: T) {
//        navigationPath.append(page)
//    }
//
//    enum AppPage: Hashable {
//        case home
//        case settings
//        case profile(userID: Int)
//        case productDetail(product: Product)
//        // Add other pages as needed
//    }
//
//    // Example functions to handle specific navigation actions
//    func showSettings() {
//        settingsCoordinator = SettingsCoordinator(navigationPath: navigationBinding)
//        settingsCoordinator?.start()
//    }
//
//    func showProfile(for userID: Int) {
//        push(AppPage.profile(userID: userID))
//    }
//
//    func showProductDetail(for productID: Int) {
//        let product = Product(id: productID, name: "Sample Product")
//        push(AppPage.productDetail(product: product))
//    }
//}

