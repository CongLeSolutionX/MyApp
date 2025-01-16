//
//  AppCoordinatorTests.swift
//  MyAppTests
//
//  Created by Cong Le on 1/16/25.
//

import XCTest
@testable import MyApp


class AppCoordinatorTests: XCTestCase {

    var appCoordinator: AppCoordinator = AppCoordinator()
    
    override func setUp() {
        super.setUp()
        appCoordinator = AppCoordinator() // Reset appCoordinator before each test
    }
    
    override func tearDown() {
        // Any cleanup if necessary
        super.tearDown()
    }

    // Test initialization
    func test_initialization() {
        XCTAssertNotNil(appCoordinator, "AppCoordinator should not be nil after initialization.")
        XCTAssertTrue(appCoordinator.navigationPath.isEmpty, "Navigation path should be empty upon initialization.")
    }

    // Test starting the coordinator
    func test_start() {
        appCoordinator.start()
        XCTAssertTrue(appCoordinator.navigationPath.isEmpty, "Navigation path should be empty after start.")
    }

    // Test pushing a route
    func test_push() {
        appCoordinator.push(.home)
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one route after push.")
        XCTAssertEqual(appCoordinator.navigationPath.last, .home, "Last route should be .home.")
    }

    // Test popping a route
    func test_pop() {
        appCoordinator.push(.home)
        appCoordinator.push(.profile(userID: 42))
        XCTAssertEqual(appCoordinator.navigationPath.count, 2, "Navigation path should contain two routes before pop.")

        appCoordinator.pop()
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one route after pop.")
        XCTAssertEqual(appCoordinator.navigationPath.last, .home, "Last route should be .home after pop.")
    }

    // Test popping to root
    func test_popToRoot() {
        appCoordinator.push(.home)
        appCoordinator.push(.profile(userID: 42))
        appCoordinator.push(.productDetail(product: Product(id: 101, name: "Test Product")))
        XCTAssertEqual(appCoordinator.navigationPath.count, 3, "Navigation path should contain three routes before popToRoot.")

        appCoordinator.popToRoot()
        XCTAssertTrue(appCoordinator.navigationPath.isEmpty, "Navigation path should be empty after popToRoot.")
    }

    // Test showing profile
    func test_showProfile() {
        appCoordinator.showProfile(for: 42)
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one route after showProfile.")
        if case let .profile(userID) = appCoordinator.navigationPath.last {
            XCTAssertEqual(userID, 42, "UserID in the last route should be 42.")
        } else {
            XCTFail("Last route should be .profile(userID: 42).")
        }
    }

    // Test showing product detail
    func test_showProductDetail() {
        appCoordinator.showProductDetail(for: 101)
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one route after showProductDetail.")
        if case let .productDetail(product) = appCoordinator.navigationPath.last {
            XCTAssertEqual(product.id, 101, "Product ID in the last route should be 101.")
            XCTAssertEqual(product.name, "Sample Product", "Product name should be 'Sample Product'.")
        } else {
            XCTFail("Last route should be .productDetail(product: Product).")
        }
    }

    // Test showing settings
    func test_showSettings() {
        appCoordinator.showSettings()
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one route after showSettings.")
        XCTAssertEqual(appCoordinator.navigationPath.last, .settings, "Last route should be .settings.")
    }

    // Test showing privacy settings
    func test_showPrivacySettings() {
        appCoordinator.showPrivacySettings()
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one route after showPrivacySettings.")
        XCTAssertEqual(appCoordinator.navigationPath.last, .privacySettings, "Last route should be .privacySettings.")
    }

    // Test showing notification settings
    func test_showNotificationSettings() {
        appCoordinator.showNotificationSettings()
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one route after showNotificationSettings.")
        XCTAssertEqual(appCoordinator.navigationPath.last, .notificationSettings, "Last route should be .notificationSettings.")
    }

    // Test pushing multiple routes
    func test_pushMultipleRoutes() {
        appCoordinator.push(.home)
        appCoordinator.push(.settings)
        appCoordinator.push(.privacySettings)
        XCTAssertEqual(appCoordinator.navigationPath.count, 3, "Navigation path should contain three routes after pushing multiple routes.")
        XCTAssertEqual(appCoordinator.navigationPath[0], .home, "First route should be .home.")
        XCTAssertEqual(appCoordinator.navigationPath[1], .settings, "Second route should be .settings.")
        XCTAssertEqual(appCoordinator.navigationPath[2], .privacySettings, "Third route should be .privacySettings.")
    }

    // Test handling deep link
    func test_handleDeepLink() {
        let url = URL(string: "myapp://product/101")!
        appCoordinator.handleDeepLink(url)
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one route after handling deep link.")
        if case let .productDetail(product) = appCoordinator.navigationPath.last {
            XCTAssertEqual(product.id, 101, "Product ID in the last route should be 101.")
        } else {
            XCTFail("Last route should be .productDetail(product: Product).")
        }
    }
}
