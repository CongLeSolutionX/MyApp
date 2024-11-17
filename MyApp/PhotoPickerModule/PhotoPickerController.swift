//
//  PhotoPickerController.swift
//  MyApp
//
//  Created by Cong Le on 11/16/24.
//
//

import UIKit
import PhotosUI
import Photos

// MARK: - Protocol Definitions

protocol PhotoLibraryProtocol {
    var authorizationStatus: PHAuthorizationStatus { get }
    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void)
}

protocol PhotoPickerViewControllerProtocol {
    var delegate: PHPickerViewControllerDelegate? { get set }
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

// MARK: - Protocol Extensions

extension PHPhotoLibrary: PhotoLibraryProtocol {
    var authorizationStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                handler(status)
            }
        }
    }
}

extension PHPickerViewController: PhotoPickerViewControllerProtocol {}

// MARK: - PhotoPickerController

class PhotoPickerController: UIViewController {
    
    // MARK: - Properties
    
    private let photoLibrary: PhotoLibraryProtocol
    private var pickerViewController: PhotoPickerViewControllerProtocol?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(selectPhotoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    
    init(photoLibrary: PhotoLibraryProtocol = PHPhotoLibrary.shared()) {
        self.photoLibrary = photoLibrary
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.photoLibrary = PHPhotoLibrary.shared()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(selectPhotoButton)
        
        NSLayoutConstraint.activate([
            // ImageView Constraints
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Button Constraints
            selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectPhotoButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)
        ])
    }
    
    // MARK: - Button Action
    
    @objc private func selectPhotoButtonTapped() {
        handlePhotoLibraryPermission()
    }
    
    // MARK: - Permission Handling
    
    private func handlePhotoLibraryPermission() {
        switch photoLibrary.authorizationStatus {
        case .authorized, .limited:
            presentPhotoPicker()
        case .notDetermined:
            photoLibrary.requestAuthorization { [weak self] status in
                if status == .authorized || status == .limited {
                    self?.presentPhotoPicker()
                } else {
                    self?.showPermissionDeniedAlert()
                }
            }
        default:
            showPermissionDeniedAlert()
        }
    }
    
    // MARK: - Photo Picker Presentation
    
    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        pickerViewController = picker
        present(picker, animated: true)
    }
    
    // MARK: - Alert Presentation
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Access Denied",
            message: "Please enable photo library access in Settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension PhotoPickerController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            guard let uiImage = image as? UIImage else { return }
            DispatchQueue.main.async {
                self?.imageView.image = uiImage
            }
        }
    }
}
