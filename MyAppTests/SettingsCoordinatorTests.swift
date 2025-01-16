//
//  SettingsCoordinatorTests.swift
//  MyApp
//
//  Created by Cong Le on 1/16/25.
//

import ViewInspector
import SwiftUI
import XCTest
@testable import MyApp

// Extend PrivacySettingsView and NotificationSettingsView to conform to Inspectable
//extension PrivacySettingsView: @retroactive Inspectable {}
//extension NotificationSettingsView: @retroactive Inspectable {}

class SettingsCoordinatorTests: XCTestCase {
    
    var settingsCoordinator: SettingsCoordinator = SettingsCoordinator()
    
    override func setUp() {
        super.setUp()
        settingsCoordinator = SettingsCoordinator()
    }
    
    override func tearDown() {
        // Any cleanup if necessary
        super.tearDown()
    }
    
    func test_initialization() {
        XCTAssertNotNil(settingsCoordinator, "SettingsCoordinator should not be nil after initialization.")
    }
    
    func test_showPrivacySettings_returnsPrivacySettingsView() throws {
        let anyView = settingsCoordinator.showPrivacySettings()
        // Unwrap AnyView to get the underlying view
        let unwrappedView = try anyView.inspect().find(PrivacySettingsView.self)
        XCTAssertNotNil(unwrappedView, "showPrivacySettings() should return PrivacySettingsView.")
    }
    
    func test_showNotificationSettings_returnsNotificationSettingsView() throws {
        let anyView = settingsCoordinator.showNotificationSettings()
        // Unwrap AnyView to get the underlying view
        let unwrappedView = try anyView.inspect().find(NotificationSettingsView.self)
        XCTAssertNotNil(unwrappedView, "showNotificationSettings() should return NotificationSettingsView.")
    }
}
