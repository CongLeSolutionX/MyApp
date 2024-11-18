//
//  MockPhotoLibrary.swift
//  MyApp
//
//  Created by Cong Le on 11/17/24.
//

import XCTest
import Photos
import PhotosUI
import UIKit
@testable import MyApp



// MARK: - Mock Classes

// Mock PhotoLibraryProtocol to simulate different authorization statuses
class MockPhotoLibrary: PhotoLibraryProtocol {
    var authorizationStatus: PHAuthorizationStatus
    
    // Closure to simulate requesting authorization
    var requestAuthorizationHandler: (( @escaping (PHAuthorizationStatus) -> Void) -> Void)?
    
    init(status: PHAuthorizationStatus) {
        self.authorizationStatus = status
    }
    
    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
        if let handlerClosure = requestAuthorizationHandler {
            handlerClosure(handler)
        } else {
            // Default behavior: immediately return current status
            DispatchQueue.main.async {
                handler(self.authorizationStatus)
            }
        }
    }
}

// Mock PhotoPickerViewControllerProtocol if needed
class MockPhotoPickerViewController: PhotoPickerViewControllerProtocol {
    var delegate: PHPickerViewControllerDelegate?
    
    private(set) var presentedViewController: UIViewController?
    var presentCalled = false
    var presentedWith: UIViewController?
    var animated: Bool = false
    var completion: (() -> Void)?
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentCalled = true
        presentedWith = viewControllerToPresent
        animated = flag
        self.completion = completion
    }
}
