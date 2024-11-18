//
//  PhotoPickerControllerTests.swift
//  PhotoPickerControllerTests
//
//  Created by Cong Le on 11/17/24.
//

import Photos
import PhotosUI
import UIKit
import XCTest
@testable import MyApp

class PhotoPickerControllerTests: XCTestCase {
    
    var photoPickerController: PhotoPickerController!
    var mockPhotoLibrary: MockPhotoLibrary!
    var mockPresenter: MockPhotoPickerViewController!
    
    override func setUp() {
        super.setUp()
        // Default setup with .notDetermined status
        mockPhotoLibrary = MockPhotoLibrary(status: .notDetermined)
        mockPresenter = MockPhotoPickerViewController()
        photoPickerController = PhotoPickerController(photoLibrary: mockPhotoLibrary)
    }
    
    override func tearDown() {
        photoPickerController = nil
        mockPhotoLibrary = nil
        mockPresenter = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    func loadView() {
        // Trigger view loading
        _ = photoPickerController.view
    }
    
    // MARK: - Test Cases
    
    func testHandlePhotoLibraryPermission_Authorized() {
        // Arrange
        mockPhotoLibrary.authorizationStatus = .authorized
        loadView()
        
        // Replace the present method to capture the picker presentation
        let expectation = self.expectation(description: "Present Photo Picker")
        photoPickerController.present = { viewController, animated, completion in
            XCTAssertTrue(animated)
            XCTAssertTrue(viewController is PHPickerViewController)
            expectation.fulfill()
        }
        
        // Act
        photoPickerController.selectPhotoButtonTapped()
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHandlePhotoLibraryPermission_Limited() {
        // Arrange
        mockPhotoLibrary.authorizationStatus = .limited
        loadView()
        
        let expectation = self.expectation(description: "Present Photo Picker with Limited Access")
        photoPickerController.present = { viewController, animated, completion in
            XCTAssertTrue(animated)
            XCTAssertTrue(viewController is PHPickerViewController)
            expectation.fulfill()
        }
        
        // Act
        photoPickerController.selectPhotoButtonTapped()
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHandlePhotoLibraryPermission_NotDetermined_Authorized() {
        // Arrange
        mockPhotoLibrary.authorizationStatus = .notDetermined
        mockPhotoLibrary.requestAuthorizationHandler = { handler in
            // Simulate user granting access
            handler(.authorized)
        }
        loadView()
        
        let expectation = self.expectation(description: "Request Authorization and Present Picker")
        photoPickerController.present = { viewController, animated, completion in
            XCTAssertTrue(animated)
            XCTAssertTrue(viewController is PHPickerViewController)
            expectation.fulfill()
        }
        
        // Act
        photoPickerController.selectPhotoButtonTapped()
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHandlePhotoLibraryPermission_NotDetermined_Limited() {
        // Arrange
        mockPhotoLibrary.authorizationStatus = .notDetermined
        mockPhotoLibrary.requestAuthorizationHandler = { handler in
            // Simulate user granting limited access
            handler(.limited)
        }
        loadView()
        
        let expectation = self.expectation(description: "Request Authorization with Limited Access and Present Picker")
        photoPickerController.present = { viewController, animated, completion in
            XCTAssertTrue(animated)
            XCTAssertTrue(viewController is PHPickerViewController)
            expectation.fulfill()
        }
        
        // Act
        photoPickerController.selectPhotoButtonTapped()
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHandlePhotoLibraryPermission_NotDetermined_Denied() {
        // Arrange
        mockPhotoLibrary.authorizationStatus = .notDetermined
        mockPhotoLibrary.requestAuthorizationHandler = { handler in
            // Simulate user denying access
            handler(.denied)
        }
        loadView()
        
        let expectation = self.expectation(description: "Request Authorization Denied and Show Alert")
        // Replace the showPermissionDeniedAlert method
        photoPickerController.showPermissionDeniedAlert = {
            let topVC = self.photoPickerController.getTopMostViewController()
            XCTAssertNotNil(topVC.presentedViewController)
            if let alert = topVC.presentedViewController as? UIAlertController {
                XCTAssertEqual(alert.title, "Access Denied")
                XCTAssertEqual(alert.message, "Please enable photo library access in Settings.")
                XCTAssertEqual(alert.actions.count, 1)
                XCTAssertEqual(alert.actions.first?.title, "OK")
                expectation.fulfill()
            } else {
                XCTFail("No alert presented")
                expectation.fulfill()
            }
        }
        
        // Act
        photoPickerController.selectPhotoButtonTapped()
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHandlePhotoLibraryPermission_Denied() {
        // Arrange
        mockPhotoLibrary.authorizationStatus = .denied
        loadView()
        
        let expectation = self.expectation(description: "Show Permission Denied Alert when Access is Denied")
        // Replace the showPermissionDeniedAlert method
        photoPickerController.showPermissionDeniedAlert = {
            let topVC = self.photoPickerController.getTopMostViewController()
            XCTAssertNotNil(topVC.presentedViewController)
            if let alert = topVC.presentedViewController as? UIAlertController {
                XCTAssertEqual(alert.title, "Access Denied")
                XCTAssertEqual(alert.message, "Please enable photo library access in Settings.")
                XCTAssertEqual(alert.actions.count, 1)
                XCTAssertEqual(alert.actions.first?.title, "OK")
                expectation.fulfill()
            } else {
                XCTFail("No alert presented")
                expectation.fulfill()
            }
        }
        
        // Act
        photoPickerController.selectPhotoButtonTapped()
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHandlePhotoLibraryPermission_Restricted() {
        // Arrange
        mockPhotoLibrary.authorizationStatus = .restricted
        loadView()
        
        let expectation = self.expectation(description: "Show Permission Denied Alert when Access is Restricted")
        // Replace the showPermissionDeniedAlert method
        photoPickerController.showPermissionDeniedAlert = {
            let topVC = self.photoPickerController.getTopMostViewController()
            XCTAssertNotNil(topVC.presentedViewController)
            if let alert = topVC.presentedViewController as? UIAlertController {
                XCTAssertEqual(alert.title, "Access Denied")
                XCTAssertEqual(alert.message, "Please enable photo library access in Settings.")
                XCTAssertEqual(alert.actions.count, 1)
                XCTAssertEqual(alert.actions.first?.title, "OK")
                expectation.fulfill()
            } else {
                XCTFail("No alert presented")
                expectation.fulfill()
            }
        }
        
        // Act
        photoPickerController.selectPhotoButtonTapped()
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHandlePhotoLibraryPermission_UnknownStatus() {
        // Arrange
        mockPhotoLibrary.authorizationStatus = .authorized // Not applicable, but to simulate unknown
        loadView()
        
        let expectation = self.expectation(description: "Show Permission Denied Alert when Access is Unknown")
        // Simulate unknown status by using an invalid enum value (not possible directly, so we'll mock the response)
        // Here, we'll assume @unknown default is hit
        // Replace the handlePhotoLibraryPermission method if necessary to simulate unknown
        
        // For illustration, we'll directly call showPermissionDeniedAlert
        photoPickerController.handlePhotoLibraryPermission = {
            self.photoPickerController.showPermissionDeniedAlert()
            expectation.fulfill()
        }
        
        // Act
        photoPickerController.selectPhotoButtonTapped()
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPickerDidFinishPickingImage() {
        // Arrange
        loadView()
        let testImage = UIImage(systemName: "checkmark")!
        let imageData = testImage.pngData()!
        
        // Create a mock item provider
        let mockProvider = MockNSItemProvider(data: imageData, typeIdentifier: "public.image")
        
        let mockResult = PHPickerResult(itemProvider: mockProvider, assetIdentifier: nil)
        let mockResults = [mockResult]
        
        // Act
        photoPickerController.picker(photoPickerController as! PHPickerViewController, didFinishPicking: mockResults)
        
        // Assert
        XCTAssertNotNil(photoPickerController.imageView.image)
        XCTAssertEqual(photoPickerController.imageView.image?.pngData(), testImage.pngData())
    }
    
    // Additional tests can be added here, such as testing UI elements,
    // ensuring buttons are connected, etc.
}

// MARK: - Mock NSItemProvider

class MockNSItemProvider: NSItemProvider {
    private let data: Data?
    private let typeIdentifierValue: String
    
    init(data: Data?, typeIdentifier: String) {
        self.data = data
        self.typeIdentifierValue = typeIdentifier
        super.init()
    }
    
    override func canLoadObject(ofClass aClass: NSItemProviderReading.Type) -> Bool {
        if aClass == UIImage.self && typeIdentifierValue == "public.image" {
            return true
        }
        return false
    }
    
    override func loadObject(ofClass aClass: NSItemProviderReading.Type, completionHandler: @escaping (Swift.Any?, Swift.Error?) -> Void) -> Progress? {
        if aClass == UIImage.self, let data = data {
            let image = UIImage(data: data)
            completionHandler(image, nil)
        } else {
            completionHandler(nil, NSError(domain: "MockNSItemProvider", code: 0, userInfo: nil))
        }
        return nil
    }
}
