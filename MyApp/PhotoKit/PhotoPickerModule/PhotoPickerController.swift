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

// MARK: - Protocol Definitions

protocol PhotoLibraryProtocol {
    var authorizationStatus: PHAuthorizationStatus { get }
    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void)
    func register(_ observer: PHPhotoLibraryChangeObserver)
    func unregisterChangeObserver(_ observer: PHPhotoLibraryChangeObserver)
}

protocol PhotoPickerViewControllerProtocol {
    var delegate: PHPickerViewControllerDelegate? { get set }
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

// MARK: - Protocol Extensions

extension PHPhotoLibrary: PhotoLibraryProtocol {
    var authorizationStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
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
    private var assetsFetchResults: PHFetchResult<PHAsset>?
    private var imageManager: PHCachingImageManager?
    
    private var livePhotoView: PHLivePhotoView?
    private var assetCollection: PHAssetCollection?
    
    /// Observes changes in the photo library
    private var photoLibraryObserver: NSObjectProtocol?
    
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
    
    // MARK: - Initializers
    
    init(photoLibrary: PhotoLibraryProtocol = PHPhotoLibrary.shared()) {
        self.photoLibrary = photoLibrary
        super.init(nibName: nil, bundle: nil)
        self.imageManager = PHCachingImageManager()
    }
    
    required init?(coder: NSCoder) {
        self.photoLibrary = PHPhotoLibrary.shared()
        super.init(coder: coder)
        self.imageManager = PHCachingImageManager()
    }
    
    deinit {
        // Unregister from photo library changes
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Register for photo library changes
        photoLibrary.register(self)
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
    
    @objc fileprivate func selectPhotoButtonTapped() {
        handlePhotoLibraryPermission()
    }
    
    @objc fileprivate func savePhotoButtonTapped() {
        saveImageToPhotoLibrary()
    }
    
    // MARK: - Permission Handling
    
    fileprivate func handlePhotoLibraryPermission() {
        switch photoLibrary.authorizationStatus {
        case .authorized, .limited:
            print("Photo Library Access: Granted")
            presentPhotoPicker()
            
        case .notDetermined:
            print("Photo Library Access: Not Determined")
            photoLibrary.requestAuthorization { [weak self] status in
                switch status {
                case .authorized, .limited:
                    print("Photo Library Access Granted")
                    self?.presentPhotoPicker()
                case .denied, .restricted:
                    print("Photo Library Access Denied")
                    self?.showPermissionDeniedAlert()
                default:
                    print("Photo Library Access: Unknown Status")
                    self?.showPermissionDeniedAlert()
                }
            }
            
        case .denied, .restricted:
            print("Photo Library Access: Denied or Restricted")
            showPermissionDeniedAlert()
            
        @unknown default:
            print("Photo Library Access: Unknown Status")
            showPermissionDeniedAlert()
        }
    }
    
    // MARK: - Photo Picker Presentation
    
    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .any(of: [.images, .livePhotos])
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
    
    // MARK: - Fetching Assets
    
    private func fetchAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assetsFetchResults = PHAsset.fetchAssets(with: fetchOptions)
    }
    
    // MARK: - Requesting Images
    
    private func requestImage(for asset: PHAsset) {
        let targetSize = CGSize(width: 200, height: 200)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        // Check if asset is a Live Photo
        if asset.mediaSubtypes.contains(.photoLive) {
            requestLivePhoto(for: asset, targetSize: targetSize)
        } else {
            imageManager?.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { [weak self] image, info in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }
    }
    
    // MARK: - Requesting Live Photos
    
    private func requestLivePhoto(for asset: PHAsset, targetSize: CGSize) {
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager?.requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { [weak self] livePhoto, info in
            if let livePhoto = livePhoto {
                DispatchQueue.main.async {
                    // Remove existing Live Photo view if any
                    self?.livePhotoView?.removeFromSuperview()
                    let livePhotoView = PHLivePhotoView(frame: self?.imageView.frame ?? .zero)
                    livePhotoView.livePhoto = livePhoto
                    self?.view.addSubview(livePhotoView)
                    self?.livePhotoView = livePhotoView
                }
            }
        }
    }
    
    // MARK: - Saving Images to Photo Library
    
    private func saveImageToPhotoLibrary() {
        guard let image = imageView.image else { return }
        PHPhotoLibrary.shared().performChanges({
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
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            // Load UIImage
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }
                guard let uiImage = image as? UIImage else { return }
                DispatchQueue.main.async {
                    self?.imageView.image = uiImage
                    // Remove Live Photo view if any
                    self?.livePhotoView?.removeFromSuperview()
                }
            }
        } else if provider.canLoadObject(ofClass: PHLivePhoto.self) {
            // Load Live Photo
            provider.loadObject(ofClass: PHLivePhoto.self) { [weak self] livePhoto, error in
                if let error = error {
                    print("Error loading live photo: \(error.localizedDescription)")
                    return
                }
                guard let livePhoto = livePhoto as? PHLivePhoto else { return }
                DispatchQueue.main.async {
                    // Remove existing Live Photo view if any
                    self?.livePhotoView?.removeFromSuperview()
                    let livePhotoView = PHLivePhotoView(frame: self?.imageView.frame ?? .zero)
                    livePhotoView.livePhoto = livePhoto
                    self?.view.addSubview(livePhotoView)
                    self?.livePhotoView = livePhotoView
                }
            }
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotoPickerController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Handle changes to the photo library (e.g., update UI or assets)
        print("Photo library did change.")
        fetchAssets()
    }
}

