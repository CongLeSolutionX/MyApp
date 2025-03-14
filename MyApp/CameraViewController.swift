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

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ItemSelectionViewControllerDelegate {
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        // Disable UI until the session runs.
        [metadataObjectTypesButton, sessionPresetsButton, cameraButton, zoomSlider].forEach { $0?.isEnabled = false }
        previewView.addGestureRecognizer(openBarcodeURLGestureRecognizer)
        previewView.session = session
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                if !granted { self.setupResult = .notAuthorized }
                self.sessionQueue.resume()
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
                    let message = NSLocalizedString("AVCamBarcode doesn't have permission to use the camera. Please change privacy settings.", comment: "Camera permission denied")
                    let alertController = UIAlertController(title: "AVCamBarcode", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default) { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    })
                    self.present(alertController, animated: true)
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Unable to capture media", comment: "Capture session configuration failed")
                    let alertController = UIAlertController(title: "AVCamBarcode", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    self.present(alertController, animated: true)
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
    
    override var shouldAutorotate: Bool { !previewView.isResizingRegionOfInterest }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let connection = previewView.videoPreviewLayer.connection {
            let deviceOrient = UIDevice.current.orientation
            guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrient),
                  deviceOrient.isPortrait || deviceOrient.isLandscape else { return }
            connection.videoOrientation = newVideoOrientation
            
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
    private var rectOfInterestWidth = Double() // Percentage value 0.0...1.0
    private var rectOfInterestHeight = Double() // Percentage value 0.0...1.0
    
    private func configureSession() {
        guard setupResult == .success else { return }
        session.beginConfiguration()
        
        do {
            let defaultVideoDevice: AVCaptureDevice? = {
                if let backDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                    return backDevice
                } else if let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    return frontDevice
                }
                return nil
            }()
            
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
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if self.windowOrientation != .unknown,
                       let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.windowOrientation) {
                        initialVideoOrientation = videoOrientation
                    }
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Could not add video device input.")
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
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: metadataObjectsQueue)
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
            
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
            print("Could not add metadata output.")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        setRecommendedZoomFactor()
        session.commitConfiguration()
    }
    
    private let metadataOutput = AVCaptureMetadataOutput()
    private let metadataObjectsQueue = DispatchQueue(label: "metadata objects queue")
    
    private lazy var sessionPresetsButton: UIButton = UIButton()
    private func availableSessionPresets() -> [AVCaptureSession.Preset] {
        let presets: [AVCaptureSession.Preset] = [.photo, .low, .medium, .high, .cif352x288, .vga640x480, .hd1280x720, .iFrame960x540, .iFrame1280x720, .hd1920x1080, .hd4K3840x2160]
        return presets.filter { session.canSetSessionPreset($0) }
    }
    
    private func selectSessionPreset() {
        let vc = ItemSelectionViewController<AVCaptureSession.Preset>(delegate: self,
                                                                      identifier: sessionPresetItemSelectionIdentifier,
                                                                      allItems: availableSessionPresets(),
                                                                      selectedItems: [session.sessionPreset],
                                                                      allowsMultipleSelection: false)
        presentItemSelectionViewController(vc)
    }
    
    // MARK: - Device Configuration
    
    private lazy var cameraButton: UIButton = UIButton()
    private lazy var cameraUnavailableLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
    
    private func changeCamera() {
        [metadataObjectTypesButton, sessionPresetsButton, cameraButton, zoomSlider].forEach { $0?.isEnabled = false }
        removeMetadataObjectOverlayLayers()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let currentPosition = self.videoDeviceInput.device.position
            let preferredPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
            let devices = self.videoDeviceDiscoverySession.devices
            if let newDevice = devices.first(where: { $0.position == preferredPosition }) {
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
                    print("Error while switching camera: \(error)")
                }
            }
            DispatchQueue.main.async {
                [self.metadataObjectTypesButton, self.sessionPresetsButton, self.cameraButton, self.zoomSlider].forEach { $0?.isEnabled = true }
                let maxZoom = min(self.videoDeviceInput.device.activeFormat.videoMaxZoomFactor, 8.0)
                self.zoomSlider.maximumValue = Float(maxZoom)
                self.zoomSlider.value = Float(self.videoDeviceInput.device.videoZoomFactor)
            }
        }
    }
    
    private lazy var zoomSlider: UISlider = UISlider()
    private func zoomCamera(with zoomSlider: UISlider) {
        do {
            try videoDeviceInput.device.lockForConfiguration()
            videoDeviceInput.device.videoZoomFactor = CGFloat(zoomSlider.value)
            videoDeviceInput.device.unlockForConfiguration()
        } catch {
            print("Could not lock device for zoom configuration: \(error)")
        }
    }
    
    private func setRecommendedZoomFactor() {
        let minFocus = Float(videoDeviceInput.device.minimumFocusDistance)
        guard minFocus != -1 else { return }
        let fieldOfView = videoDeviceInput.device.activeFormat.videoFieldOfView
        let minimumSubjectDistance = minimumSubjectDistanceForCode(fieldOfView: fieldOfView,
                                                                   minimumCodeSize: 20,
                                                                   previewFillPercentage: Float(rectOfInterestWidth))
        if minimumSubjectDistance < minFocus {
            let zoomFactor = minFocus / minimumSubjectDistance
            do {
                try videoDeviceInput.device.lockForConfiguration()
                videoDeviceInput.device.videoZoomFactor = CGFloat(zoomFactor)
                videoDeviceInput.device.unlockForConfiguration()
            } catch {
                print("Error setting zoom factor: \(error)")
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
        let obs1 = session.observe(\.isRunning, options: .new) { [weak self] _, change in
            guard let self = self, let running = change.newValue else { return }
            DispatchQueue.main.async {
                self.metadataObjectTypesButton.isEnabled = running
                self.sessionPresetsButton.isEnabled = running
                self.cameraButton.isEnabled = running && (self.videoDeviceDiscoverySession.devices.count > 1)
                self.zoomSlider.isEnabled = running
                let maxZoom = min(self.videoDeviceInput.device.activeFormat.videoMaxZoomFactor, 8.0)
                self.zoomSlider.maximumValue = Float(maxZoom)
                self.zoomSlider.value = Float(self.videoDeviceInput.device.videoZoomFactor)
                if !running { self.removeMetadataObjectOverlayLayers() }
                if running {
                    self.previewView.setRegionOfInterestWithProposedRegionOfInterest(self.previewView.regionOfInterest)
                }
            }
        }
        keyValueObservations.append(obs1)
        
        let obs2 = previewView.observe(\.regionOfInterest, options: .new) { [weak self] _, change in
            guard let self = self, let roi = change.newValue else { return }
            DispatchQueue.main.async {
                self.removeMetadataObjectOverlayLayers()
                let metadataROI = self.previewView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: roi)
                self.sessionQueue.async { self.metadataOutput.rectOfInterest = metadataROI }
            }
        }
        keyValueObservations.append(obs2)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(sessionRuntimeError(notification:)), name: .AVCaptureSessionRuntimeError, object: session)
        nc.addObserver(self, selector: #selector(sessionWasInterrupted(notification:)), name: .AVCaptureSessionWasInterrupted, object: session)
        nc.addObserver(self, selector: #selector(sessionInterruptionEnded(notification:)), name: .AVCaptureSessionInterruptionEnded, object: session)
    }
    
    private func removeObservers() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: .AVCaptureSessionInterruptionEnded, object: session)
        nc.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: session)
        nc.removeObserver(self, name: .AVCaptureSessionRuntimeError, object: session)
        keyValueObservations.forEach { $0.invalidate() }
        keyValueObservations.removeAll()
    }
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        print("Capture session runtime error: \(error)")
        if error.code == .mediaServicesWereReset {
            sessionQueue.async { [weak self] in
                if let strongSelf = self, strongSelf.isSessionRunning {
                    strongSelf.session.startRunning()
                    strongSelf.isSessionRunning = strongSelf.session.isRunning
                }
            }
        }
    }
    
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        if let userInfo = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? NSNumber,
           let reason = AVCaptureSession.InterruptionReason(rawValue: userInfo.intValue) {
            print("Capture session was interrupted. Reason: \(reason)")
            if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                cameraUnavailableLabel.isHidden = false
                cameraUnavailableLabel.alpha = 0
                UIView.animate(withDuration: 0.25) {
                    self.cameraUnavailableLabel.alpha = 1
                }
            }
        }
    }
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
        if !cameraUnavailableLabel.isHidden {
            UIView.animate(withDuration: 0.25, animations: {
                self.cameraUnavailableLabel.alpha = 0
            }) { _ in
                self.cameraUnavailableLabel.isHidden = true
            }
        }
    }
    
    // MARK: - Metadata Object Overlays
    
    private var metadataObjectTypesButton: UIButton!
    
    private func selectMetadataObjectTypes() {
        let selectionVC = ItemSelectionViewController<AVMetadataObject.ObjectType>(delegate: self,
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
    
    private func createMetadataObjectOverlay(with metadataObject: AVMetadataObject) -> MetadataObjectLayer {
        guard let transformedObj = previewView.videoPreviewLayer.transformedMetadataObject(for: metadataObject) else {
            return MetadataObjectLayer()
        }
        
        let overlayLayer = MetadataObjectLayer()
        overlayLayer.metadataObject = transformedObj
        overlayLayer.lineJoin = .round
        overlayLayer.lineWidth = 7.0
        overlayLayer.strokeColor = view.tintColor.withAlphaComponent(0.7).cgColor
        overlayLayer.fillColor = view.tintColor.withAlphaComponent(0.3).cgColor
        
        if let barcodeObj = transformedObj as? AVMetadataMachineReadableCodeObject {
            let barcodePath = barcodeOverlayPathWithCorners(barcodeObj.corners)
            overlayLayer.path = barcodePath
            let text: String? = {
                if let stringValue = barcodeObj.stringValue, !stringValue.isEmpty { return stringValue }
                if let descriptor = barcodeObj.descriptor {
                    switch descriptor {
                    case is CIQRCodeDescriptor: return "<QR Code Binary Data Present>"
                    case is CIAztecCodeDescriptor: return "<Aztec Code Binary Data Present>"
                    case is CIPDF417CodeDescriptor: return "<PDF417 Code Binary Data Present>"
                    case is CIDataMatrixCodeDescriptor: return "<Data Matrix Code Binary Data Present>"
                    default: fatalError("Unexpected barcode descriptor: \(descriptor)")
                    }
                }
                return nil
            }()
            if let text = text {
                let barcodeBounds = barcodePath.boundingBox
                let fontSize: CGFloat = 19
                let minHeight: CGFloat = fontSize + 4
                let textHeight = max(barcodeBounds.size.height, minHeight)
                let textLayer = CATextLayer()
                textLayer.alignmentMode = .center
                textLayer.bounds = CGRect(x: 0, y: 0, width: barcodeBounds.size.width, height: textHeight)
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = UIFont.boldSystemFont(ofSize: fontSize)
                textLayer.fontSize = fontSize
                textLayer.position = CGPoint(x: barcodeBounds.midX, y: barcodeBounds.midY)
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
        } else if let faceObj = transformedObj as? AVMetadataFaceObject {
            overlayLayer.path = CGPath(rect: faceObj.bounds, transform: nil)
        }
        return overlayLayer
    }
    
    private func barcodeOverlayPathWithCorners(_ corners: [CGPoint]) -> CGMutablePath {
        let path = CGMutablePath()
        if let first = corners.first {
            path.move(to: first)
            for corner in corners.dropFirst() { path.addLine(to: corner) }
            path.closeSubpath()
        }
        return path
    }
    
    private var removeMetadataObjectOverlayLayersTimer: Timer?
    
    @objc
    private func removeMetadataObjectOverlayLayers() {
        metadataObjectOverlayLayers.forEach { $0.removeFromSuperlayer() }
        metadataObjectOverlayLayers.removeAll()
        removeMetadataObjectOverlayLayersTimer?.invalidate()
        removeMetadataObjectOverlayLayersTimer = nil
    }
    
    private func addMetadataObjectOverlayLayersToVideoPreviewView(_ layers: [MetadataObjectLayer]) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layers.forEach { previewView.videoPreviewLayer.addSublayer($0) }
        CATransaction.commit()
        metadataObjectOverlayLayers = layers
        removeMetadataObjectOverlayLayersTimer = Timer.scheduledTimer(timeInterval: 1,
                                                                      target: self,
                                                                      selector: #selector(removeMetadataObjectOverlayLayers),
                                                                      userInfo: nil,
                                                                      repeats: false)
    }
    
    private lazy var openBarcodeURLGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(openBarcodeURL(with:)))
    }()
    
    @objc
    private func openBarcodeURL(with gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: previewView)
        for overlay in metadataObjectOverlayLayers {
            guard let path = overlay.path, path.contains(touchPoint, using: .winding, transform: .identity) else { continue }
            if let barcodeObj = overlay.metadataObject as? AVMetadataMachineReadableCodeObject,
               let stringValue = barcodeObj.stringValue,
               let url = URL(string: stringValue) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true)
                break
            }
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if metadataObjectsOverlayLayersDrawingSemaphore.wait(timeout: .now()) == .success {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.removeMetadataObjectOverlayLayers()
                let overlays = metadataObjects.map { self.createMetadataObjectOverlay(with: $0) }
                self.addMetadataObjectOverlayLayersToVideoPreviewView(overlays)
                self.metadataObjectsOverlayLayersDrawingSemaphore.signal()
            }
        }
    }
    
    // MARK: - ItemSelectionViewControllerDelegate
    
    let metadataObjectTypeItemSelectionIdentifier = "MetadataObjectTypes"
    let sessionPresetItemSelectionIdentifier = "SessionPreset"
    
    private func presentItemSelectionViewController<Item>(_ vc: ItemSelectionViewController<Item>) {
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.barTintColor = .black
        nav.navigationBar.tintColor = view.tintColor
        present(nav, animated: true)
    }
    
    func itemSelectionViewController<Item>(_ vc: ItemSelectionViewController<Item>, didFinishSelectingItems selectedItems: [Item]) {
        let identifier = vc.identifier
        if identifier == metadataObjectTypeItemSelectionIdentifier {
            guard let selectedTypes = selectedItems as? [AVMetadataObject.ObjectType] else {
                fatalError("Expected [AVMetadataObject.ObjectType] for selected items.")
            }
            sessionQueue.async { self.metadataOutput.metadataObjectTypes = selectedTypes }
        } else if identifier == sessionPresetItemSelectionIdentifier {
            guard let preset = selectedItems.first as? AVCaptureSession.Preset else {
                fatalError("Expected AVCaptureSession.Preset type for selected item.")
            }
            sessionQueue.async {
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
