//
//  AppRoute.swift
//  MyApp
//
//  Created by Cong Le on 1/16/25.
//

import Foundation

enum AppRoute: Hashable {
    // Main app pages
    case home
    case profile(userID: Int)
    case productDetail(product: Product)

    // Settings pages
    case settings
    case privacySettings
    case notificationSettings
}
