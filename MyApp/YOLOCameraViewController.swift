//
//  YOLOCameraViewController.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import UIKit
import AVKit
import Vision
import SwiftUI

class YOLOCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - UI Elements
    
    let videoPreview = UIView()
    let labelTime = UILabel()
    let labelName = UILabel()
    let segmentedControl = UISegmentedControl(items: ["YOLOv8n", "YOLOv8s", "YOLOv8m", "YOLOv8l", "YOLOv8x"])
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let zoomLabel = UILabel()
    let focusLabel = UILabel()
    let versionLabel = UILabel()
    let logoImageView = UIImageView(image: UIImage(named: "ultralytics_yolo_logotype"))
    let labelSliderConf = UILabel()
    let sliderConf = UISlider()
    let labelSliderIoU = UILabel()
    let sliderIoU = UISlider()
    let labelSlider = UILabel()  // Combined label for both sliders (optional, based on image)
    let slider = UISlider()     // Combined slider (optional, based on image)
    
    let toolbar = UIToolbar()
    let playButton = UIButton(type: .system)
    let pauseButton = UIButton(type: .system)
    let actionButton = UIButton(type: .system) // For the share button.
    
    // MARK: - Vision Properties
    // Add Vision properties here if needed for object detection (placeholders for now).
    //  private var detectionOverlay: CALayer! = nil
    //  private var requests = [VNRequest]()
    
    // MARK: - AV Properties
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupCaptureSession()
        setupVision() // Call a setupVision function
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .black // Important for the safe area insets
        
        // Video Preview
        videoPreview.backgroundColor = .black
        videoPreview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoPreview)
        
        // Labels
        labelTime.text = "0.00s"
        labelTime.textColor = .white
        labelTime.font = UIFont.systemFont(ofSize: 14)
        labelTime.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelTime)
        
        labelName.text = "Label"
        labelName.textColor = .white
        labelName.font = UIFont.boldSystemFont(ofSize: 24)
        labelName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelName)
        
        // Segmented Control
        segmentedControl.selectedSegmentIndex = 2 // "YOLOv8m" as in the screenshot
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating() // Start animating initially
        
        // Zoom, Focus, Version Labels
        zoomLabel.text = "1.00x"
        zoomLabel.textColor = .white
        zoomLabel.font = UIFont.systemFont(ofSize: 14)
        zoomLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(zoomLabel)
        
        focusLabel.text = "Focus"
        focusLabel.textColor = .white
        focusLabel.font = UIFont.systemFont(ofSize: 14)
        focusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(focusLabel)
        
        versionLabel.text = "Version 0.0.0(1)"
        versionLabel.textColor = .white
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(versionLabel)
        
        // Logo Image View
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        // Slider Labels
        labelSliderConf.text = "0.25 Confidence Threshold"
        labelSliderConf.textColor = .white
        labelSliderConf.font = UIFont.systemFont(ofSize: 14)
        labelSliderConf.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelSliderConf)
        
        labelSliderIoU.text = "0.45 IoU Threshold"
        labelSliderIoU.textColor = .white
        labelSliderIoU.font = UIFont.systemFont(ofSize: 14)
        labelSliderIoU.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelSliderIoU)
        
        // Sliders
        sliderConf.minimumValue = 0
        sliderConf.maximumValue = 1
        sliderConf.value = 0.25  // Initial value
        sliderConf.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sliderConf)
        
        sliderIoU.minimumValue = 0
        sliderIoU.maximumValue = 1
        sliderIoU.value = 0.45  // Initial value
        sliderIoU.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sliderIoU)
        
        // Combined Slider Label and Slider (Optional)
        labelSlider.text = "0 items (max 30)"
        labelSlider.textColor = .white
        labelSlider.font = UIFont.systemFont(ofSize: 14)
        labelSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelSlider)
        
        slider.minimumValue = 0
        slider.maximumValue = 30
        slider.value = 0 // Initial Value
        slider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(slider)
        
        // Toolbar
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        // Toolbar Buttons
        
        //Play button
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        
        //Pause button
        pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
        
        //Action button
        actionButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 20 // Adjust spacing as needed
        
        let playBarButton = UIBarButtonItem(customView: playButton)
        let pauseBarButton = UIBarButtonItem(customView: pauseButton)
        let actionBarButtonItem = UIBarButtonItem(customView: actionButton)
        
        toolbar.items = [flexibleSpace, playBarButton, fixedSpace, pauseBarButton, flexibleSpace, actionBarButtonItem, flexibleSpace]
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // Video Preview
            videoPreview.topAnchor.constraint(equalTo: safeArea.topAnchor),
            videoPreview.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            videoPreview.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            videoPreview.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            // Labels
            labelTime.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            labelTime.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            
            labelName.topAnchor.constraint(equalTo: labelTime.bottomAnchor, constant: 4),
            labelName.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            segmentedControl.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor, constant: -8),
            
            // Activity Indicator (Centered)
            activityIndicator.centerXAnchor.constraint(equalTo: videoPreview.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: videoPreview.centerYAnchor),
            
            // Zoom, Focus and version Labels
            zoomLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            zoomLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            
            focusLabel.topAnchor.constraint(equalTo: zoomLabel.bottomAnchor, constant: 28), // position below slider
            focusLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            
            versionLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 8),
            versionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            
            // Logo Image View
            logoImageView.topAnchor.constraint(equalTo: videoPreview.topAnchor, constant: 8), // or another appropriate position
            logoImageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            logoImageView.widthAnchor.constraint(equalToConstant: 120), // Adjust size as needed
            logoImageView.heightAnchor.constraint(equalToConstant: 40), // Adjust size as needed
            
            // Slider Labels
            labelSliderConf.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            labelSliderConf.topAnchor.constraint(equalTo: focusLabel.bottomAnchor, constant: 4), // Adjust spacing
            
            labelSliderIoU.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            labelSliderIoU.topAnchor.constraint(equalTo: sliderConf.bottomAnchor, constant: 1), // Place below sliderConf
            
            // Sliders
            sliderConf.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 5),
            sliderConf.topAnchor.constraint(equalTo: labelSliderConf.bottomAnchor, constant: 4),
            sliderConf.trailingAnchor.constraint(equalTo: focusLabel.trailingAnchor), //align with the focus label
            
            sliderIoU.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 5),
            sliderIoU.topAnchor.constraint(equalTo: labelSliderIoU.bottomAnchor, constant: 4),
            sliderIoU.trailingAnchor.constraint(equalTo: focusLabel.trailingAnchor), //align with the focus label
            
            // Combined Slider Label and Slider (Optional)
            labelSlider.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            labelSlider.bottomAnchor.constraint(equalTo: zoomLabel.topAnchor, constant: -4), // Positioned above zoomLabel
            
            slider.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            slider.topAnchor.constraint(equalTo: labelSlider.bottomAnchor, constant: 4),
            slider.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            
            // Toolbar
            toolbar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
    // MARK: - AV Setup
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        // Select a device.
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureOutput = AVCaptureVideoDataOutput()
            captureSession.addOutput(captureOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            
            // Preview Layer
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds // Important: Use view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            videoPreview.layer.addSublayer(previewLayer)
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    // MARK: - Vision Setup
    func setupVision() {
        // Placeholder: Set up Vision requests here
        // Example (replace with your actual YOLO model setup):
        /*
         guard let modelURL = Bundle.main.url(forResource: "YourYOLOModel", withExtension: "mlmodelc") else {
         return assertionFailure("Model file is missing")
         }
         
         do {
         let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
         let recognitions = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
         DispatchQueue.main.async(execute: {
         if let results = request.results {
         self.drawVisionRequestResults(results) // You'd implement this
         }
         })
         })
         self.requests = [recognitions]
         } catch let error {
         print("Error loading Vision model: \(error)")
         }
         */
    }
    
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // *** Important: Vision requests are performed here.
        // Example:
        /*
         let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:]) // Adjust orientation!
         do {
         try imageRequestHandler.perform(self.requests) // Assuming 'requests' is your array of VNRequest
         } catch {
         print(error)
         }
         */
    }
    
    // MARK: - Button Actions
    @objc func playTapped() {
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    @objc func pauseTapped() {
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    @objc func actionButtonTapped() {
        // Implement sharing functionality here.  A simple example:
        let textToShare = "Check out this cool app!"
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        // For iPad, you need to present the UIActivityViewController as a popover.
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = actionButton // Set the source view
            popoverPresentationController.sourceRect = actionButton.bounds // Set the source rect
            popoverPresentationController.permittedArrowDirections = [.down,.up]
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    // Add any helper functions here, such as drawVisionRequestResults (if you are doing object detection).
    /*
     func drawVisionRequestResults(_ results: [Any]) {
     CATransaction.begin()
     CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
     detectionOverlay.sublayers = nil // Clear previous detections
     
     for observation in results where observation is VNRecognizedObjectObservation {
     guard let objectObservation = observation as? VNRecognizedObjectObservation else {
     continue
     }
     
     // ... rest of your drawing logic ...
     }
     CATransaction.commit()
     }
     */
    
    //Important for device rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (_) in
            // Update the preview layer's frame and connection orientation.
            if let connection = self.previewLayer.connection, connection.isVideoOrientationSupported {
                let interfaceOrientation = self.view.window?.windowScene?.interfaceOrientation ?? .unknown
                
                switch interfaceOrientation{
                case .portrait:
                    connection.videoOrientation = .portrait
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeRight //Correct the orientation
                case .landscapeRight:
                    connection.videoOrientation = .landscapeLeft //Correct the orientation
                case .portraitUpsideDown:
                    connection.videoOrientation = .portraitUpsideDown
                default:
                    connection.videoOrientation = .portrait
                }
            }
            self.previewLayer.frame = self.view.bounds
            
        }, completion: nil)
    }
}

// MARK: - Preview
struct ContentView: View {
    var body: some View {
        UIKitViewControllerWrapper()
            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
    }
}

// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}
