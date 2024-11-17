//
//  PhotoPickerController.swift
//  MyApp
//
//  Created by Cong Le on 11/16/24.
//

import UIKit
import PhotosUI
import Foundation

class PhotoPickerController: UIViewController, PHPickerViewControllerDelegate {
    
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(selectPhotoButton)
        
        NSLayoutConstraint.activate([
            selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectPhotoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        selectPhotoButton.addTarget(self, action: #selector(selectPhotoButtonTapped), for: .touchUpInside)
    }
    
    @objc func selectPhotoButtonTapped() {
        checkPhotoLibraryPermission()
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            // Access already granted, proceed.
            print("Photo library access already authorized.")
            presentPicker()
        case .denied, .restricted:
            // Handle denied or restricted access.
            print("Photo library access denied or restricted.")
        case .notDetermined:
            // Request authorization
            //            PHPhotoLibrary.requestAuthorization { newStatus in
            //                if newStatus == .authorized {
            //                    DispatchQueue.main.async {
            //                        self.presentPicker()
            //                    }
            //                }
            //            }
            PhotoPermissionsManager.requestPhotoLibraryPermission { status in
                // Handle the authorization response as above in the request snippet
                switch status {
                case .authorized:
                    // Access already granted, proceed.
                    print("Photo library access authorized.")
                case .denied:
                    // Handle denied access.
                    print("Photo library access denied.")
                case .restricted:
                    // Handle restricted access.
                    print("Photo library access restricted.")
                case .notDetermined:
                    print("Photo library access not determined.")
                case .limited:
                    print("Photo library access limited.")
                @unknown default:
                    print("Unknown photo library access status.")
                }
            }
        case .limited:
            let alert = UIAlertController(title: "Access Denied", message: "Please enable photo library access in Settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            print("Photo library access limited.")
        @unknown default:
            print("Unknown photo library access status.")
        }
    }
    
    func presentPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                if image is UIImage {
                    DispatchQueue.main.async {
                        // Update UI with the image
                        print("TODO: Update UI with the image")
                    }
                }
            }
        }
    }
}

class PhotoPermissionsManager {
    
    static func requestPhotoLibraryPermission(completion: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
}
