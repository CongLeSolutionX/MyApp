//
//  PhotoPickerController.swift
//  MyApp
//
//  Created by Cong Le on 11/16/24.
//

import UIKit
import PhotosUI

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
            presentPicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    DispatchQueue.main.async {
                        self.presentPicker()
                    }
                }
            }
        case .denied, .restricted:
            let alert = UIAlertController(title: "Access Denied", message: "Please enable photo library access in Settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .limited:
            print("Limited access to photo library.")
        @unknown default:
            print("Unknown authorization status.")
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
                    }
                }
            }
        }
    }
}
