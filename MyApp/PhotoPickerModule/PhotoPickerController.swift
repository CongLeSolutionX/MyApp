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
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(selectPhotoButton)
        NSLayoutConstraint.activate([
            selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectPhotoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        selectPhotoButton.addTarget(self, action: #selector(selectPhotoButtonTapped), for: .touchUpInside)
    }
    
    @objc private func selectPhotoButtonTapped() {
        checkPhotoLibraryPermission()
    }
    
    private func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            presentPicker()
        case .notDetermined:
            requestPhotoLibraryAccess()
        default:
            showPermissionDeniedAlert()
        }
    }
    
    private func requestPhotoLibraryAccess() {
        PhotoPermissionsManager.requestPhotoLibraryPermission { [weak self] status in
            if status == .authorized {
                self?.presentPicker()
            } else {
                self?.showPermissionDeniedAlert()
            }
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(title: "Access Denied", message: "Please enable photo library access in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func presentPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        // TODO: Update UI with the image
                        print("Image selected and available")
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
