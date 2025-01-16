//
//  SettingsCoordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI
class SettingsCoordinator: ObservableObject, Coordinator {
    @Binding var navigationPath: [AnyHashable]
    
    init(navigationPath: Binding<[AnyHashable]>) {
        self._navigationPath = navigationPath
    }
    
    func start() {
        push(SettingsPage.main)
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
    
    enum SettingsPage: Hashable {
        case main
        case privacy
        case notifications
    }
}
