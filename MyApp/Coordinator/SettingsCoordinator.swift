//
//  SettingsCoordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI


class SettingsCoordinator: ObservableObject, Coordinator {
    @Binding var navigationPath: NavigationPath

    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }

    func start() {
        push(SettingsPage.main)
    }

    func push<T: Hashable>(_ page: T) {
        navigationPath.append(page)
    }

    enum SettingsPage: Hashable {
        case main
        case privacy
        case notifications
        // Add other settings pages as needed
    }
}

