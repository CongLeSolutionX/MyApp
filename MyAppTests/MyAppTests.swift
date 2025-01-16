//
//  MyAppTests.swift
//  MyAppTests
//
//  Created by Cong Le on 1/16/25.
//

import XCTest
@testable import MyApp

class AppCoordinatorTests: XCTestCase {
    func testAppCoordinatorInitialization() {
        let appCoordinator = AppCoordinator()
        XCTAssertTrue(appCoordinator.navigationPath.isEmpty, "AppCoordinator should start with an empty navigation path.")
        XCTAssertNil(appCoordinator.settingsCoordinator, "SettingsCoordinator should be nil upon initialization.")
    }
}
