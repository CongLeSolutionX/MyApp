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
    
    func test_appCoordinator_initialization() {
        let appCoordinator = AppCoordinator()
        XCTAssertTrue(appCoordinator.navigationPath.isEmpty, "AppCoordinator should start with an empty navigation path.")
        XCTAssertNil(appCoordinator.settingsCoordinator, "SettingsCoordinator should be nil upon initialization.")
    }
    
    func test_appCoordinator_start() {
        let appCoordinator = AppCoordinator()
        appCoordinator.start()
        
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one item after start.")
        
        if let firstPage = appCoordinator.navigationPath.first as? AppCoordinator.AppPage {
            XCTAssertEqual(firstPage, .home, "The first page should be '.home'.")
        } else {
            XCTFail("First item in navigation path is not of type AppPage.")
        }
    }
    
    func test_appCoordinator_push() {
        let appCoordinator = AppCoordinator()
        let product = Product(id: 1, name: "Test Product")
        appCoordinator.push(AppCoordinator.AppPage.productDetail(product: product))
        
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one item after push.")
        
        if let firstPage = appCoordinator.navigationPath.first as? AppCoordinator.AppPage {
            switch firstPage {
            case .productDetail(let pushedProduct):
                XCTAssertEqual(pushedProduct, product, "The product pushed should match the one provided.")
            default:
                XCTFail("First page is not '.productDetail'.")
            }
        } else {
            XCTFail("First item in navigation path is not of type AppPage.")
        }
    }
    
    func test_appCoordinator_pop() {
        let appCoordinator = AppCoordinator()
        appCoordinator.start()
        let userID = 42
        appCoordinator.showProfile(for: userID)
        
        XCTAssertEqual(appCoordinator.navigationPath.count, 2, "Navigation path should contain two items before pop.")
        
        appCoordinator.pop()
        XCTAssertEqual(appCoordinator.navigationPath.count, 1, "Navigation path should contain one item after pop.")
        
        if let firstPage = appCoordinator.navigationPath.first as? AppCoordinator.AppPage {
            XCTAssertEqual(firstPage, .home, "After popping, the remaining page should be '.home'.")
        } else {
            XCTFail("First item in navigation path is not of type AppPage.")
        }
    }
    
    // Continue with other tests...
}
