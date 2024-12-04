//
//  PhotoPickerController.swift
//  MyApp
//
//  Created by Cong Le on 12/2/24.
//
/*
 Abstract:
 Handling photo library authorization.
 Fetching and displaying assets (images and Live Photos).
 Using PHImageManager to request images and Live Photos.
 Implementing asset caching for performance.
 Saving new images to the photo library.
 Observing changes to the photo library.
 Handling permissions and limited library access.
 Using the Photos picker (PHPickerViewController and PhotosPicker in SwiftUI).
 
 */
import UIKit
import PhotosUI
import Photos

// MARK: - PhotoPickerController

class PhotoPickerController: UIViewController {
    
    // MARK: - Properties
    
    private let photoLibrary: PHPhotoLibrary = .shared()
    private let imageManager = PHCachingImageManager()
    
    private var livePhotoView: PHLivePhotoView?
    
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
    
    private lazy var savePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Photo", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(savePhotoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Register for photo library changes
        photoLibrary.register(self)
    }
    
    deinit {
        // Unregister from photo library changes
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(selectPhotoButton)
        view.addSubview(savePhotoButton)
        
        NSLayoutConstraint.activate([
            // ImageView Constraints
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Select Photo Button Constraints
            selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectPhotoButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            // Save Photo Button Constraints
            savePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            savePhotoButton.topAnchor.constraint(equalTo: selectPhotoButton.bottomAnchor, constant: 10)
        ])
    }
    
    // MARK: - Button Actions
    
    @objc private func selectPhotoButtonTapped() {
        handlePhotoLibraryPermission()
    }
    
    @objc private func savePhotoButtonTapped() {
        saveImageToPhotoLibrary()
    }
    
    // MARK: - Permission Handling
    
    private func handlePhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            presentPhotoPicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.presentPhotoPicker()
                    } else {
                        self?.showPermissionDeniedAlert()
                    }
                }
            }
        default:
            showPermissionDeniedAlert()
        }
    }
    
    // MARK: - Photo Picker Presentation
    
    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images, .livePhotos])
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
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
    
    // MARK: - Requesting Images
    
    private func displayAsset(_ asset: PHAsset) {
        let targetSize = CGSize(width: 200, height: 200)
        if asset.mediaSubtypes.contains(.photoLive) {
            requestLivePhoto(for: asset, targetSize: targetSize)
        } else {
            requestImage(for: asset, targetSize: targetSize)
        }
    }
    
    private func requestImage(for asset: PHAsset, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.livePhotoView?.removeFromSuperview()
            }
        }
    }
    
    private func requestLivePhoto(for asset: PHAsset, targetSize: CGSize) {
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestLivePhoto(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] livePhoto, _ in
            DispatchQueue.main.async {
                if let livePhoto = livePhoto {
                    self?.updateLivePhotoView(with: livePhoto)
                }
            }
        }
    }
    
    private func updateLivePhotoView(with livePhoto: PHLivePhoto) {
        livePhotoView?.removeFromSuperview()
        let livePhotoView = PHLivePhotoView(frame: imageView.frame)
        livePhotoView.livePhoto = livePhoto
        view.addSubview(livePhotoView)
        self.livePhotoView = livePhotoView
    }
    
    // MARK: - Saving Images to Photo Library
    
    private func saveImageToPhotoLibrary() {
        guard let image = imageView.image else { return }
        photoLibrary.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.showAlert(title: "Success", message: "Image saved to Photo Library.")
                } else if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Showing Alerts
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension PhotoPickerController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: PHLivePhoto.self) {
            // Load Live Photo
            provider.loadObject(ofClass: PHLivePhoto.self) { [weak self] livePhoto, error in
                if let error = error {
                    print("Error loading live photo: \(error.localizedDescription)")
                    return
                }
                if let livePhoto = livePhoto as? PHLivePhoto {
                    DispatchQueue.main.async {
                        self?.updateLivePhotoView(with: livePhoto)
                    }
                }
            }
        } else if provider.canLoadObject(ofClass: UIImage.self) {
            // Load UIImage
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self?.imageView.image = uiImage
                        self?.livePhotoView?.removeFromSuperview()
                    }
                }
            }
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotoPickerController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Handle changes to the photo library if needed
        print("Photo library did change.")
    }
}
