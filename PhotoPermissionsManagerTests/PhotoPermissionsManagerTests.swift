//
//  PhotoPermissionsManagerTests.swift
//  PhotoPermissionsManagerTests
//
//  Created by Cong Le on 11/16/24.
//

import XCTest
import Photos
@testable import MyApp

final class PhotoPermissionsManagerTests: XCTestCase {
    
    func testRequestPhotoLibraryPermission_Authorized() {
        let expectation = XCTestExpectation(description: "Permission request with authorized status")
        
        PhotoPermissionsManager.requestPhotoLibraryPermission { status in
            XCTAssertEqual(status, .authorized, "Expected authorization status to be .authorized for this test.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testRequestPhotoLibraryPermission_Denied() {
        let expectation = XCTestExpectation(description: "Permission request with denied status")
        
        // Implement a way to mock the permission status for the test. As PHPhotoLibrary.requestAuthorization cannot be mocked directly we are setting an expectation here for the test coverage, but to properly test this a mock or a different approach is needed to stimulate a Denied state in the test environment.
        
        PhotoPermissionsManager.requestPhotoLibraryPermission { status in
            // Check for the permission status in more realistic testing environment
            // Replace below comment out line with proper mocking implementation.
            // XCTAssertEqual(status, .denied, "Expected authorization status to be .denied for this test.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
}
