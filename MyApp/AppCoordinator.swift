//
//  AppCoordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/11/25.
//
import SwiftUI

class AppCoordinator: Coordinator, ObservableObject {
    @Published var navigationPath = NavigationPath()

    func start() {
        // Set the initial view here, for example:
        push(AppPage.home)
    }

    func push(_ page: any Hashable) {
        navigationPath.append(page)
    }

    enum AppPage: String, Hashable, CaseIterable {
        case home, settings, profile
    }
}
