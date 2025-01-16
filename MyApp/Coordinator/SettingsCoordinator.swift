//
//  SettingsCoordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI

class SettingsCoordinator: ObservableObject {
    enum SettingsRoute: Hashable {
        case privacy
        case notifications
    }

    func showPrivacySettings() -> AnyView {
        AnyView(PrivacySettingsView())
    }

    func showNotificationSettings() -> AnyView {
        AnyView(NotificationSettingsView())
    }
}
