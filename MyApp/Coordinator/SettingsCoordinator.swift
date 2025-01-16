//
//  SettingsCoordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI
class SettingsCoordinator: ObservableObject {
    @Published var navigationPath: [SettingsPage] = []

    enum SettingsPage: Hashable {
        case privacy
        case notifications
    }

    func push(_ page: SettingsPage) {
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
}
