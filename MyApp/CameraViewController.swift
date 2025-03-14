//
//  CameraViewController.swift
//  MyApp
//
//  Created by Cong Le on 3/14/25.
//

/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 The view controller for the camera interface.
 */
import UIKit
import AVFoundation
import SafariServices

class CameraViewController: UIViewController,
                            AVCaptureMetadataOutputObjectsDelegate,
                            ItemSelectionViewControllerDelegate {
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable UI controls until session is running.
        metadataObjectTypesButton.isEnabled = false
        sessionPresetsButton.isEnabled = false
        cameraButton.isEnabled = false
        zoomSlider.isEnabled = false
        
        previewView.addGestureRecognizer(openBarcodeURLGestureRecognizer)
        previewView.session = session
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if !granted { self?.setupResult = .notAuthorized }
                self?.sessionQueue.resume()
            }
        default:
            setupResult = .notAuthorized
        }
        
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            switch self.setupResult {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
            case .notAuthorized:
                DispatchQueue.main.async {
                    let message = NSLocalizedString("AVCamBarcode doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCamBarcode", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "AVCamBarcode", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    override var shouldAutorotate: Bool {
        return !previewView.isResizingRegionOfInterest
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let connection = previewView.videoPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                  deviceOrientation.isPortrait || deviceOrientation.isLandscape else { return }
            
            connection.videoOrientation = newOrientation
            
            coordinator.animate(alongsideTransition: { [weak self] _ in
                guard let self = self else { return }
                let newROI = self.previewView.videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: self.metadataOutput.rectOfInterest)
                self.previewView.setRegionOfInterestWithProposedRegionOfInterest(newROI)
            }, completion: { [weak self] _ in
                self?.removeMetadataObjectOverlayLayers()
            })
        }
    }
    
    var windowOrientation: UIInterfaceOrientation {
        return view.window?.windowScene?.interfaceOrientation ?? .unknown
    }
    
    // MARK: - Session Management
    
    private enum SessionSetupResult { case success, notAuthorized, configurationFailed }
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var setupResult: SessionSetupResult = .success
    var videoDeviceInput: AVCaptureDeviceInput!
    
    private var previewView: PreviewView!
    
    private var rectOfInterestWidth = Double()  // Percentage (0.0 to 1.0)
    private var rectOfInterestHeight = Double() // Percentage (0.0 to 1.0)
    
    private func configureSession() {
        guard setupResult == .success else { return }
        session.beginConfiguration()
        do {
            // Choose the appropriate camera.
            let defaultVideoDevice: AVCaptureDevice? =
                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) ??
                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            
            guard let videoDevice = defaultVideoDevice else {
                print("Could not get video device")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    var initialOrientation: AVCaptureVideoOrientation = .portrait
                    if self.windowOrientation != .unknown,
                       let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.windowOrientation) {
                        initialOrientation = videoOrientation
                    }
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = initialOrientation
                }
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add metadata output.
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: metadataObjectsQueue)
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
            
            // Setup an initial rect of interest.
            let formatDimensions = CMVideoFormatDescriptionGetDimensions(videoDeviceInput.device.activeFormat.formatDescription)
            rectOfInterestWidth = Double(formatDimensions.height) / Double(formatDimensions.width)
            rectOfInterestHeight = 1.0
            let xCoordinate = (1.0 - rectOfInterestWidth) / 2.0
            let yCoordinate = (1.0 - rectOfInterestHeight) / 2.0
            let initialROI = CGRect(x: xCoordinate, y: yCoordinate, width: rectOfInterestWidth, height: rectOfInterestHeight)
            metadataOutput.rectOfInterest = initialROI
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let initialRegion = self.previewView.videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: initialROI)
                self.previewView.setRegionOfInterestWithProposedRegionOfInterest(initialRegion)
            }
        } else {
            print("Could not add metadata output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        setRecommendedZoomFactor()
        session.commitConfiguration()
    }
    
    private let metadataOutput = AVCaptureMetadataOutput()
    private let metadataObjectsQueue = DispatchQueue(label: "metadata objects queue")
    
    // UI controls created lazily.
    private lazy var sessionPresetsButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    private func availableSessionPresets() -> [AVCaptureSession.Preset] {
        let allPresets: [AVCaptureSession.Preset] = [.photo, .low, .medium, .high, .cif352x288, .vga640x480, .hd1280x720, .iFrame960x540, .iFrame1280x720, .hd1920x1080, .hd4K3840x2160]
        return allPresets.filter { session.canSetSessionPreset($0) }
    }
    
    private func selectSessionPreset() {
        let presetVC = ItemSelectionViewController<AVCaptureSession.Preset>(
            delegate: self,
            identifier: sessionPresetItemSelectionIdentifier,
            allItems: availableSessionPresets(),
            selectedItems: [session.sessionPreset],
            allowsMultipleSelection: false)
        presentItemSelectionViewController(presetVC)
    }
    
    // MARK: - Device Configuration
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    private lazy var cameraUnavailableLabel: UILabel = {
        let label = UILabel()
        label.text = "Camera unavailable"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                                 mediaType: .video,
                                                                                 position: .unspecified)
    
    private func changeCamera() {
        metadataObjectTypesButton.isEnabled = false
        sessionPresetsButton.isEnabled = false
        cameraButton.isEnabled = false
        zoomSlider.isEnabled = false
        removeMetadataObjectOverlayLayers()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let currentPosition = self.videoDeviceInput.device.position
            let preferredPosition: AVCaptureDevice.Position = (currentPosition == .back ? .front : .back)
            let devices = self.videoDeviceDiscoverySession.devices
            guard let newDevice = devices.first(where: { $0.position == preferredPosition }) else { return }
            
            do {
                let newInput = try AVCaptureDeviceInput(device: newDevice)
                self.session.beginConfiguration()
                self.session.removeInput(self.videoDeviceInput)
                let previousPreset = self.session.sessionPreset
                self.session.sessionPreset = .high
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                    self.videoDeviceInput = newInput
                } else {
                    self.session.addInput(self.videoDeviceInput)
                }
                if self.session.canSetSessionPreset(previousPreset) {
                    self.session.sessionPreset = previousPreset
                }
                self.setRecommendedZoomFactor()
                self.session.commitConfiguration()
            } catch {
                print("Error occurred while creating video device input: \(error)")
            }
            
            DispatchQueue.main.async {
                self.metadataObjectTypesButton.isEnabled = true
                self.sessionPresetsButton.isEnabled = true
                self.cameraButton.isEnabled = true
                self.zoomSlider.isEnabled = true
                let maxZoom = min(self.videoDeviceInput.device.activeFormat.videoMaxZoomFactor, 8.0)
                self.zoomSlider.maximumValue = Float(maxZoom)
                self.zoomSlider.value = Float(self.videoDeviceInput.device.videoZoomFactor)
            }
        }
    }
    
    private lazy var zoomSlider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(zoomCamera(with:)), for: .valueChanged)
        return slider
    }()
    
    @objc
    private func zoomCamera(with slider: UISlider) {
        do {
            try videoDeviceInput.device.lockForConfiguration()
            videoDeviceInput.device.videoZoomFactor = CGFloat(slider.value)
            videoDeviceInput.device.unlockForConfiguration()
        } catch {
            print("Could not lock device for configuration: \(error)")
        }
    }
    
    private func setRecommendedZoomFactor() {
        let deviceMinimumFocusDistance = Float(videoDeviceInput.device.minimumFocusDistance)
        guard deviceMinimumFocusDistance != -1 else { return }
        
        let deviceFOV = videoDeviceInput.device.activeFormat.videoFieldOfView
        let minSubjectDistance = minimumSubjectDistanceForCode(fieldOfView: deviceFOV, minimumCodeSize: 20, previewFillPercentage: Float(rectOfInterestWidth))
        if minSubjectDistance < deviceMinimumFocusDistance {
            let zoomFactor = deviceMinimumFocusDistance / minSubjectDistance
            do {
                try videoDeviceInput.device.lockForConfiguration()
                videoDeviceInput.device.videoZoomFactor = CGFloat(zoomFactor)
                videoDeviceInput.device.unlockForConfiguration()
            } catch {
                print("Could not lock for configuration: \(error)")
            }
        }
    }
    
    private func minimumSubjectDistanceForCode(fieldOfView: Float, minimumCodeSize: Float, previewFillPercentage: Float) -> Float {
        let radians = degreesToRadians(fieldOfView / 2)
        let filledCodeSize = minimumCodeSize / previewFillPercentage
        return filledCodeSize / tan(radians)
    }
    
    private func degreesToRadians(_ degrees: Float) -> Float {
        return degrees * .pi / 180
    }
    
    // MARK: - KVO and Notifications
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    private func addObservers() {
        let isRunningObservation = session.observe(\.isRunning, options: .new) { [weak self] _, change in
            guard let self = self, let isRunning = change.newValue else { return }
            DispatchQueue.main.async {
                self.metadataObjectTypesButton.isEnabled = isRunning
                self.sessionPresetsButton.isEnabled = isRunning
                self.cameraButton.isEnabled = isRunning && self.videoDeviceDiscoverySession.devices.count > 1
                self.zoomSlider.isEnabled = isRunning
                let maxZoom = min(self.videoDeviceInput.device.activeFormat.videoMaxZoomFactor, 8.0)
                self.zoomSlider.maximumValue = Float(maxZoom)
                self.zoomSlider.value = Float(self.videoDeviceInput.device.videoZoomFactor)
                
                if !isRunning { self.removeMetadataObjectOverlayLayers() }
                if isRunning { self.previewView.setRegionOfInterestWithProposedRegionOfInterest(self.previewView.regionOfInterest) }
            }
        }
        keyValueObservations.append(isRunningObservation)
        
        let roiObservation = previewView.observe(\.regionOfInterest, options: .new) { [weak self] _, change in
            guard let self = self, let roi = change.newValue else { return }
            DispatchQueue.main.async {
                self.removeMetadataObjectOverlayLayers()
                let metadataROI = self.previewView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: roi)
                self.sessionQueue.async {
                    self.metadataOutput.rectOfInterest = metadataROI
                }
            }
        }
        keyValueObservations.append(roiObservation)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(sessionRuntimeError(notification:)), name: .AVCaptureSessionRuntimeError, object: session)
        notificationCenter.addObserver(self, selector: #selector(sessionWasInterrupted(notification:)), name: .AVCaptureSessionWasInterrupted, object: session)
        notificationCenter.addObserver(self, selector: #selector(sessionInterruptionEnded(notification:)), name: .AVCaptureSessionInterruptionEnded, object: session)
    }
    
    private func removeObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: .AVCaptureSessionInterruptionEnded, object: session)
        notificationCenter.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: session)
        notificationCenter.removeObserver(self, name: .AVCaptureSessionRuntimeError, object: session)
        
        keyValueObservations.forEach { $0.invalidate() }
        keyValueObservations.removeAll()
    }
    
    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        print("Capture session runtime error: \(error)")
        if error.code == .mediaServicesWereReset {
            sessionQueue.async { [weak self] in
                guard let self = self, self.isSessionRunning else { return }
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
    
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? NSNumber,
           let reason = AVCaptureSession.InterruptionReason(rawValue: userInfoValue.intValue) {
            print("Capture session was interrupted, reason: \(reason)")
            if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                cameraUnavailableLabel.alpha = 0
                cameraUnavailableLabel.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.cameraUnavailableLabel.alpha = 1
                }
            }
        }
    }
    
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
        if !cameraUnavailableLabel.isHidden {
            UIView.animate(withDuration: 0.25, animations: {
                self.cameraUnavailableLabel.alpha = 0
            }) { _ in
                self.cameraUnavailableLabel.isHidden = true
            }
        }
    }
    
    // MARK: - Drawing Metadata Object Overlay Layers
    
    private var metadataObjectTypesButton: UIButton!
    
    private func selectMetadataObjectTypes() {
        let selectionVC = ItemSelectionViewController<AVMetadataObject.ObjectType>(
            delegate: self,
            identifier: metadataObjectTypeItemSelectionIdentifier,
            allItems: metadataOutput.availableMetadataObjectTypes,
            selectedItems: metadataOutput.metadataObjectTypes,
            allowsMultipleSelection: true)
        presentItemSelectionViewController(selectionVC)
    }
    
    private class MetadataObjectLayer: CAShapeLayer {
        var metadataObject: AVMetadataObject?
    }
    
    private let metadataObjectsOverlayLayersDrawingSemaphore = DispatchSemaphore(value: 1)
    
    private var metadataObjectOverlayLayers = [MetadataObjectLayer]()
    
    private func createMetadataObjectOverlayWithMetadataObject(_ metadataObject: AVMetadataObject) -> MetadataObjectLayer {
        guard let transformedObject = previewView.videoPreviewLayer.transformedMetadataObject(for: metadataObject) else {
            fatalError("Could not transform metadata object")
        }
        let overlayLayer = MetadataObjectLayer()
        overlayLayer.metadataObject = transformedObject
        overlayLayer.lineJoin = .round
        overlayLayer.lineWidth = 7.0
        overlayLayer.strokeColor = view.tintColor.withAlphaComponent(0.7).cgColor
        overlayLayer.fillColor = view.tintColor.withAlphaComponent(0.3).cgColor
        
        if let barcodeObject = transformedObject as? AVMetadataMachineReadableCodeObject {
            let path = barcodeOverlayPathWithCorners(barcodeObject.corners)
            overlayLayer.path = path
            var textLayerString: String?
            if let s = barcodeObject.stringValue, !s.isEmpty {
                textLayerString = s
            } else if let descriptor = barcodeObject.descriptor {
                if descriptor is CIQRCodeDescriptor {
                    textLayerString = "<QR Code Binary Data Present>"
                } else if descriptor is CIAztecCodeDescriptor {
                    textLayerString = "<Aztec Code Binary Data Present>"
                } else if descriptor is CIPDF417CodeDescriptor {
                    textLayerString = "<PDF417 Code Binary Data Present>"
                } else if descriptor is CIDataMatrixCodeDescriptor {
                    textLayerString = "<Data Matrix Code Binary Data Present>"
                } else {
                    fatalError("Unexpected barcode descriptor found: \(descriptor)")
                }
            }
            
            if let text = textLayerString {
                let overlayBounds = overlayLayer.path?.boundingBox ?? .zero
                let fontSize: CGFloat = 19
                let minimumTextLayerHeight: CGFloat = fontSize + 4
                let textLayerHeight = overlayBounds.size.height < minimumTextLayerHeight ? minimumTextLayerHeight : overlayBounds.size.height
                
                let textLayer = CATextLayer()
                textLayer.alignmentMode = .center
                textLayer.bounds = CGRect(x: 0, y: 0, width: overlayBounds.size.width, height: textLayerHeight)
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = UIFont.boldSystemFont(ofSize: fontSize).fontName as CFString
                textLayer.position = CGPoint(x: overlayBounds.midX, y: overlayBounds.midY)
                textLayer.string = NSAttributedString(string: text, attributes: [
                    .font: UIFont.boldSystemFont(ofSize: fontSize),
                    .foregroundColor: UIColor.white.cgColor,
                    .strokeWidth: -5.0,
                    .strokeColor: UIColor.black.cgColor
                ])
                textLayer.isWrapped = true
                textLayer.transform = CATransform3DInvert(CATransform3DMakeAffineTransform(previewView.transform))
                overlayLayer.addSublayer(textLayer)
            }
        } else if let faceObject = transformedObject as? AVMetadataFaceObject {
            overlayLayer.path = CGPath(rect: faceObject.bounds, transform: nil)
        }
        return overlayLayer
    }
    
    private func barcodeOverlayPathWithCorners(_ corners: [CGPoint]) -> CGMutablePath {
        let path = CGMutablePath()
        guard let first = corners.first else { return path }
        path.move(to: first)
        corners.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
    
    private var removeMetadataObjectOverlayLayersTimer: Timer?
    
    @objc private func removeMetadataObjectOverlayLayers() {
        metadataObjectOverlayLayers.forEach { $0.removeFromSuperlayer() }
        metadataObjectOverlayLayers.removeAll()
        removeMetadataObjectOverlayLayersTimer?.invalidate()
        removeMetadataObjectOverlayLayersTimer = nil
    }
    
    private func addMetadataObjectOverlayLayersToVideoPreviewView(_ overlays: [MetadataObjectLayer]) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlays.forEach { previewView.videoPreviewLayer.addSublayer($0) }
        CATransaction.commit()
        metadataObjectOverlayLayers = overlays
        removeMetadataObjectOverlayLayersTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(removeMetadataObjectOverlayLayers), userInfo: nil, repeats: false)
    }
    
    private lazy var openBarcodeURLGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(openBarcodeURL(with:)))
    }()
    
    @objc private func openBarcodeURL(with tapGR: UITapGestureRecognizer) {
        let tapPoint = tapGR.location(in: previewView)
        for overlay in metadataObjectOverlayLayers {
            if let path = overlay.path,
               path.contains(tapPoint, using: .winding, transform: .identity),
               let barcodeObject = overlay.metadataObject as? AVMetadataMachineReadableCodeObject,
               let stringValue = barcodeObject.stringValue,
               let url = URL(string: stringValue) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
                break
            }
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjectsOverlayLayersDrawingSemaphore.wait(timeout: .now()) == .success {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.removeMetadataObjectOverlayLayers()
                let overlays = metadataObjects.map { self.createMetadataObjectOverlayWithMetadataObject($0) }
                self.addMetadataObjectOverlayLayersToVideoPreviewView(overlays)
                self.metadataObjectsOverlayLayersDrawingSemaphore.signal()
            }
        }
    }
    
    // MARK: - ItemSelectionViewControllerDelegate
    
    let metadataObjectTypeItemSelectionIdentifier = "MetadataObjectTypes"
    let sessionPresetItemSelectionIdentifier = "SessionPreset"
    
    private func presentItemSelectionViewController<Item>(_ vc: ItemSelectionViewController<Item>) {
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.barTintColor = .black
        navController.navigationBar.tintColor = view.tintColor
        present(navController, animated: true, completion: nil)
    }
    
    func itemSelectionViewController<Item>(_ vc: ItemSelectionViewController<Item>, didFinishSelectingItems selectedItems: [Item]) {
        let identifier = vc.identifier
        if identifier == metadataObjectTypeItemSelectionIdentifier {
            guard let types = selectedItems as? [AVMetadataObject.ObjectType] else {
                fatalError("Expected [AVMetadataObject.ObjectType] for selection.")
            }
            sessionQueue.async { [weak self] in
                self?.metadataOutput.metadataObjectTypes = types
            }
        } else if identifier == sessionPresetItemSelectionIdentifier {
            guard let preset = selectedItems.first as? AVCaptureSession.Preset else {
                fatalError("Expected AVCaptureSession.Preset for selection.")
            }
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                self.session.beginConfiguration()
                self.session.sessionPreset = preset
                self.setRecommendedZoomFactor()
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.zoomSlider.value = Float(self.videoDeviceInput.device.videoZoomFactor)
                }
            }
        }
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}
