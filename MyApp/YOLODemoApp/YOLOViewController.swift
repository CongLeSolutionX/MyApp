// YOLOViewController.swift

import AVFoundation
import CoreMedia
import CoreML
import UIKit
import Vision

var mlModel = try! yolov8m(configuration: .init()).model

class YOLOViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private var videoPreview: UIView!
    private var overlayView: UIView!
    private var segmentedControl: UISegmentedControl!
    private var playButton: UIBarButtonItem!
    private var pauseButton: UIBarButtonItem!
    private var slider: UISlider!
    private var sliderConf: UISlider!
    private var sliderIoU: UISlider!
    private var labelName: UILabel!
    private var labelFPS: UILabel!
    private var labelZoom: UILabel!
    private var labelVersion: UILabel!
    private var labelSlider: UILabel!
    private var labelSliderConf: UILabel!
    private var labelSliderIoU: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: detector, completionHandler: {
            [weak self] request, error in
            self?.processObservations(for: request, error: error)
        })
        // NOTE: BoundingBoxView object scaling depends on request.imageCropAndScaleOption https://developer.apple.com/documentation/vision/vnimagecropandscaleoption
        request.imageCropAndScaleOption = .scaleFill  // .scaleFit, .scaleFill, .centerCrop
        return request
    }()
    
    
    
    let selection = UISelectionFeedbackGenerator()
    var detector = try! VNCoreMLModel(for: mlModel)
    var session: AVCaptureSession!
    var videoCapture: VideoCapture!
    var currentBuffer: CVPixelBuffer?
    var framesDone = 0
    var t0 = 0.0  // inference start
    var t1 = 0.0  // inference dt
    var t2 = 0.0  // inference dt smoothed
    var t3 = CACurrentMediaTime()  // FPS start
    var t4 = 0.0  // FPS dt smoothed
    
    
    // Developer mode
    let developerMode = UserDefaults.standard.bool(forKey: "developer_mode")   // developer mode selected in settings
    let save_detections = false  // write every detection to detections.txt
    let save_frames = false  // write every frame to frames.txt
    
    let maxBoundingBoxViews = 100
    var boundingBoxViews = [BoundingBoxView]()
    var colors: [String: UIColor] = [:]
    
    // Statistics Data
    private let maxDataPoints = 50
    private var inferenceTimes: [Double] = []
    private var fpsValues: [Double] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setLabels()
        setUpBoundingBoxViews()
        startVideo()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        videoPreview.frame = view.bounds
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGreen
        
        // Video Preview View
        videoPreview = UIView()
        videoPreview.backgroundColor = .yellow
        videoPreview.contentMode = .scaleAspectFill
        view.addSubview(videoPreview)
        
        // Overlay View (for adding buttons and labels)
        overlayView = UIView()
        // overlayView.backgroundColor = .red
        view.addSubview(overlayView)
        
        // Segmented Control for model selection
        segmentedControl = UISegmentedControl(items: ["YOLOv8n", "YOLOv8s", "YOLOv8m", "YOLOv8l", "YOLOv8x"])
        segmentedControl.selectedSegmentIndex = 2  // Default to YOLOv8m
        segmentedControl.addTarget(self, action: #selector(modelChanged(_:)), for: .valueChanged)
        overlayView.addSubview(segmentedControl)
        
        // Labels
        labelName = createLabel(fontSize: 18, weight: .bold)
        labelFPS = createLabel(fontSize: 16)
        labelZoom = createLabel(fontSize: 16)
        labelVersion = createLabel(fontSize: 14)
        labelSlider = createLabel(fontSize: 14)
        labelSliderConf = createLabel(fontSize: 14)
        labelSliderIoU = createLabel(fontSize: 14)
        
        // Sliders
        slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 30
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        overlayView.addSubview(slider)
        
        sliderConf = UISlider()
        sliderConf.minimumValue = 0.0
        sliderConf.maximumValue = 1.0
        sliderConf.value = 0.25
        sliderConf.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        overlayView.addSubview(sliderConf)
        
        sliderIoU = UISlider()
        sliderIoU.minimumValue = 0.0
        sliderIoU.maximumValue = 1.0
        sliderIoU.value = 0.45
        sliderIoU.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        overlayView.addSubview(sliderIoU)
        
        // Activity Indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        overlayView.addSubview(activityIndicator)
        
        // Navigation Bar Buttons
        setupNavigationBar()
        
        // Layout
        layoutUI()
    }
    
    private func setupNavigationBar() {
        // Settings button
        let settingsButton = UIBarButtonItem(
            title: "Settings",
            style: .plain,
            target: self,
            action: #selector(navigateToSettings)
        )
        
        // Statistics button
        let statisticsButton = UIBarButtonItem(
            title: "Stats",
            style: .plain,
            target: self,
            action: #selector(navigateToStatistics)
        )
        
        // Play and Pause buttons
        playButton = UIBarButtonItem(
            title: "Play",
            style: .plain,
            target: self,
            action: #selector(playButtonTapped)
        )
        pauseButton = UIBarButtonItem(
            title: "Pause",
            style: .plain,
            target: self,
            action: #selector(pauseButtonTapped)
        )
        
        navigationItem.rightBarButtonItems = [settingsButton, statisticsButton]
        navigationItem.leftBarButtonItems = [playButton, pauseButton]
    }
    
    private func layoutUI() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        sliderConf.translatesAutoresizingMaskIntoConstraints = false
        sliderIoU.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        labelName.translatesAutoresizingMaskIntoConstraints = false
        labelFPS.translatesAutoresizingMaskIntoConstraints = false
        labelZoom.translatesAutoresizingMaskIntoConstraints = false
        labelVersion.translatesAutoresizingMaskIntoConstraints = false
        labelSlider.translatesAutoresizingMaskIntoConstraints = false
        labelSliderConf.translatesAutoresizingMaskIntoConstraints = false
        labelSliderIoU.translatesAutoresizingMaskIntoConstraints = false
        
        // Overlay View
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
        
        // Segmented Control
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: overlayView.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor)
        ])
        
        // Activity Indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            
        ])
        
        // Labels and Sliders
        let labelsAndSliders = [
            labelName, labelFPS, labelZoom, labelVersion, slider, labelSlider, sliderConf, labelSliderConf, sliderIoU, labelSliderIoU
        ]
        
        var previousView: UIView = segmentedControl
        
        for view in labelsAndSliders {
            guard let view = view else {
                continue
            }
            overlayView.addSubview(view)
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 20),
                view.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -20),
                view.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 10),
            ])
            previousView = view
        }
        
        // Gesture Recognizer for Pinch to Zoom
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        videoPreview.addGestureRecognizer(pinchGesture)
    }
    
    private func createLabel(fontSize: CGFloat, weight: UIFont.Weight = .regular) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(label)
        return label
    }
    
    // Pinch to Zoom Start ---------------------------------------------------------------------------------------------
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 10.0
    var lastZoomFactor: CGFloat = 1.0
    
    @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
        let device = videoCapture.captureDevice
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer {
                    device.unlockForConfiguration()
                }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        switch pinch.state {
        case .began: fallthrough
        case .changed:
            update(scale: newScaleFactor)
            self.labelZoom.text = String(format: "%.2fx", newScaleFactor)
            self.labelZoom.font = UIFont.preferredFont(forTextStyle: .title2)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
            self.labelZoom.font = UIFont.preferredFont(forTextStyle: .body)
        default: break
        }
    } // Pinch to Zoom Start
    
    func setUpBoundingBoxViews() {
        // Ensure all bounding box views are initialized up to the maximum allowed.
        while boundingBoxViews.count < maxBoundingBoxViews {
            boundingBoxViews.append(BoundingBoxView())
        }
        
        // Retrieve class labels directly from the CoreML model's class labels, if available.
        guard let classLabels = mlModel.modelDescription.classLabels as? [String] else {
            fatalError("Class labels are missing from the model description")
        }
        
        // Assign random colors to the classes.
        for label in classLabels {
            if colors[label] == nil {  // if key not in dict
                colors[label] = UIColor(red: CGFloat.random(in: 0...1),
                                        green: CGFloat.random(in: 0...1),
                                        blue: CGFloat.random(in: 0...1),
                                        alpha: 0.6)
            }
        }
    }
    
    func startVideo() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        
        videoCapture.setUp(sessionPreset: .photo) { success in
            // .hd4K3840x2160 or .photo (4032x3024)  Warning: 4k may not work on all devices i.e. 2019 iPod
            if success {
                // Add the video preview into the UI.
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.videoCapture.previewLayer?.frame = self.videoPreview.bounds  // resize preview layer
                }
                
                // Add the bounding box layers to the UI, on top of the video preview.
                for box in self.boundingBoxViews {
                    box.addToLayer(self.videoPreview.layer)
                }
                
                // Once everything is set up, we can start capturing live video.
                self.videoCapture.start()
            }
        }
    }
    
    
    func predict(sampleBuffer: CMSampleBuffer) {
        if currentBuffer == nil, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            currentBuffer = pixelBuffer
            
            /// - Tag: MappingOrientation
            // The frame is always oriented based on the camera sensor,
            // so in most cases Vision needs to rotate it for the model to work as expected.
            let imageOrientation: CGImagePropertyOrientation
            switch UIDevice.current.orientation {
            case .portrait:
                imageOrientation = .up
            case .portraitUpsideDown:
                imageOrientation = .down
            case .landscapeLeft:
                imageOrientation = .left
            case .landscapeRight:
                imageOrientation = .right
            case .unknown:
                print("The device orientation is unknown, the predictions may be affected")
                fallthrough
            default:
                imageOrientation = .up
            }
            
            // Invoke a VNRequestHandler with that image
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: imageOrientation, options: [:])
            if UIDevice.current.orientation != .faceUp {  // stop if placed down on a table
                t0 = CACurrentMediaTime()  // inference start
                do {
                    try handler.perform([visionRequest])
                } catch {
                    print(error)
                }
                t1 = CACurrentMediaTime() - t0  // inference dt
            }
            
            currentBuffer = nil
        }
    }
    
    // MARK: - Actions
    
    @objc func modelChanged(_ sender: UISegmentedControl) {
        selection.selectionChanged()
        activityIndicator.startAnimating()
        
        /// Switch model
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.labelName.text = "YOLOv8n"
            mlModel = try! yolov8n(configuration: .init()).model
        case 1:
            self.labelName.text = "YOLOv8s"
            mlModel = try! yolov8s(configuration: .init()).model
        case 2:
            self.labelName.text = "YOLOv8m"
            mlModel = try! yolov8m(configuration: .init()).model
        case 3:
            self.labelName.text = "YOLOv8l"
            mlModel = try! yolov8l(configuration: .init()).model
        case 4:
            self.labelName.text = "YOLOv8x"
            mlModel = try! yolov8x(configuration: .init()).model
        default:
            break
        }
        setModel()
        setUpBoundingBoxViews()
        activityIndicator.stopAnimating()
    }
    
    @objc func sliderChanged(_ sender: UISlider) {
        let conf = Double(round(100 * sliderConf.value)) / 100
        let iou = Double(round(100 * sliderIoU.value)) / 100
        self.labelSliderConf.text = String(conf) + " Confidence Threshold"
        self.labelSliderIoU.text = String(iou) + " IoU Threshold"
        //detector.featureProvider = ThresholdProvider(iouThreshold: iou, confidenceThreshold: conf)
    }
    
    @objc func playButtonTapped() {
        selection.selectionChanged()
        self.videoCapture.start()
        playButton.isEnabled = false
        pauseButton.isEnabled = true
    }
    
    @objc func pauseButtonTapped() {
        selection.selectionChanged()
        //self.videoCapture.stop()
        playButton.isEnabled = true
        pauseButton.isEnabled = false
    }
    
    @objc func navigateToStatistics() {
        let statisticsVC = YOLOStatisticsViewController()
        statisticsVC.inferenceTimes = self.inferenceTimes
        statisticsVC.fpsValues = self.fpsValues
        navigationController?.pushViewController(statisticsVC, animated: true)
    }
    
    @objc func navigateToSettings() {
        let settingsVC = YOLOSettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    // MARK: - Additional Methods (Same as previous code)
    
    func setModel() {
        /// VNCoreMLModel
        detector = try! VNCoreMLModel(for: mlModel)
        //detector.featureProvider = ThresholdProvider()
        
        /// VNCoreMLRequest
        let request = VNCoreMLRequest(model: detector, completionHandler: { [weak self] request, error in
            self?.processObservations(for: request, error: error)
        })
        request.imageCropAndScaleOption = .scaleFill  // .scaleFit, .scaleFill, .centerCrop
        //visionRequest = request
        t2 = 0.0 // inference dt smoothed
        t3 = CACurrentMediaTime()  // FPS start
        t4 = 0.0  // FPS dt smoothed
    }
    
    func setLabels() {
        self.labelName.text = "YOLOv8m"
        self.labelVersion.text = "Version " + (UserDefaults.standard.string(forKey: "app_version") ?? "N/A")
        self.labelSliderConf.text = "0.25 Confidence Threshold"
        self.labelSliderIoU.text = "0.45 IoU Threshold"
        self.labelSlider.text = "Items (max 30)"
    }
    
    // Remember to collect inference time and FPS for statistics
    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let results = request.results as? [VNRecognizedObjectObservation] {
                self.show(predictions: results)
            } else {
                self.show(predictions: [])
            }
            
            // Measure FPS
            if self.t1 < 10.0 {  // valid dt
                self.t2 = self.t1 * 0.05 + self.t2 * 0.95  // smoothed inference time
            }
            self.t4 = (CACurrentMediaTime() - self.t3) * 0.05 + self.t4 * 0.95  // smoothed delivered FPS
            self.labelFPS.text = String(format: "%.1f FPS - %.1f ms", 1 / self.t4, self.t2 * 1000)  // t2 seconds to ms
            self.t3 = CACurrentMediaTime()
        }
    }
    
    func show(predictions: [VNRecognizedObjectObservation]) {
        let width = videoPreview.bounds.width  // 375 pix
        let height = videoPreview.bounds.height  // 812 pix
        var str = ""
        
        // ratio = videoPreview AR divided by sessionPreset AR
        var ratio: CGFloat = 1.0
        if videoCapture.captureSession.sessionPreset == .photo {
            ratio = (height / width) / (4.0 / 3.0)  // .photo
        } else {
            ratio = (height / width) / (16.0 / 9.0)  // .hd4K3840x2160, .hd1920x1080, .hd1280x720 etc.
        }
        
        // date
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let nanoseconds = calendar.component(.nanosecond, from: date)
        let sec_day = Double(hour) * 3600.0 + Double(minutes) * 60.0 + Double(seconds) + Double(nanoseconds) / 1E9  // seconds in the day
        
        self.labelSlider.text = String(predictions.count) + " items (max " + String(Int(slider.value)) + ")"
        for i in 0..<boundingBoxViews.count {
            if i < predictions.count && i < Int(slider.value) {
                let prediction = predictions[i]
                
                var rect = prediction.boundingBox  // normalized xywh, origin lower left
                switch UIDevice.current.orientation {
                case .portraitUpsideDown:
                    rect = CGRect(x: 1.0 - rect.origin.x - rect.width,
                                  y: 1.0 - rect.origin.y - rect.height,
                                  width: rect.width,
                                  height: rect.height)
                case .landscapeLeft:
                    rect = CGRect(x: rect.origin.y,
                                  y: 1.0 - rect.origin.x - rect.width,
                                  width: rect.height,
                                  height: rect.width)
                case .landscapeRight:
                    rect = CGRect(x: 1.0 - rect.origin.y - rect.height,
                                  y: rect.origin.x,
                                  width: rect.height,
                                  height: rect.width)
                case .unknown:
                    print("The device orientation is unknown, the predictions may be affected")
                    fallthrough
                default: break
                }
                
                if ratio >= 1 { // iPhone ratio = 1.218
                    let offset = (1 - ratio) * (0.5 - rect.minX)
                    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: offset, y: -1)
                    rect = rect.applying(transform)
                    rect.size.width *= ratio
                } else { // iPad ratio = 0.75
                    let offset = (ratio - 1) * (0.5 - rect.maxY)
                    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: offset - 1)
                    rect = rect.applying(transform)
                    rect.size.height /= ratio
                }
                
                // Scale normalized to pixels [375, 812] [width, height]
                rect = VNImageRectForNormalizedRect(rect, Int(width), Int(height))
                
                // The labels array is a list of VNClassificationObservation objects,
                // with the highest scoring class first in the list.
                let bestClass = prediction.labels[0].identifier
                let confidence = prediction.labels[0].confidence
                // print(confidence, rect)  // debug (confidence, xywh) with xywh origin top left (pixels)
                
                // Show the bounding box.
                boundingBoxViews[i].show(frame: rect,
                                         label: String(format: "%@ %.1f", bestClass, confidence * 100),
                                         color: colors[bestClass] ?? UIColor.white,
                                         alpha: CGFloat((confidence - 0.2) / (1.0 - 0.2) * 0.9))  // alpha 0 (transparent) to 1 (opaque) for conf threshold 0.2 to 1.0)
                
                if developerMode {
                    // Write
                    if save_detections {
                        str += String(format: "%.3f %.3f %.3f %@ %.2f %.1f %.1f %.1f %.1f\n",
                                      sec_day, freeSpace(), UIDevice.current.batteryLevel, bestClass, confidence,
                                      rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
                    }
                    
                    // Action trigger upon detection
                    // if false {
                    //     if (bestClass == "car") {  // "cell phone", "car", "person"
                    //         self.takePhoto(nil)
                    //         // self.pauseButton(nil)
                    //         sleep(2)
                    //     }
                    // }
                }
            } else {
                boundingBoxViews[i].hide()
            }
        }
        
        // Write
        if developerMode {
            if save_detections {
                saveText(text: str, file: "detections.txt")  // Write stats for each detection
            }
            if save_frames {
                str = String(format: "%.3f %.3f %.3f %.3f %.1f %.1f %.1f\n",
                             sec_day, freeSpace(), memoryUsage(), UIDevice.current.batteryLevel,
                             self.t1 * 1000, self.t2 * 1000, 1 / self.t4)
                saveText(text: str, file: "frames.txt")  // Write stats for each image
            }
        }
        
        // Debug
        // print(str)
        // print(UIDevice.current.identifierForVendor!)
        // saveImage()
    }
    
    // Return hard drive space (GB)
    func freeSpace() -> Double {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            return Double(values.volumeAvailableCapacityForImportantUsage!) / 1E9   // Bytes to GB
        } catch {
            print("Error retrieving storage capacity: \(error.localizedDescription)")
        }
        return 0
    }
    
    // Return RAM usage (GB)
    func memoryUsage() -> Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            return Double(taskInfo.resident_size) / 1E9   // Bytes to GB
        } else {
            return 0
        }
    }
    
    
    // Save text file
    func saveText(text: String, file: String = "saved.txt") {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            // Writing
            do {  // Append to file if it exists
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(text.data(using: .utf8)!)
                fileHandle.closeFile()
            } catch {  // Create new file and write
                do {
                    try text.write(to: fileURL, atomically: false, encoding: .utf8)
                } catch {
                    print("no file written")
                }
            }
            
            // Reading
            // do {let text2 = try String(contentsOf: fileURL, encoding: .utf8)} catch {/* error handling here */}
        }
    }
    
    // Statistics Data Management
    private func addInferenceTime(time: Double) {
        self.inferenceTimes.append(time)
        if self.inferenceTimes.count > self.maxDataPoints {
            self.inferenceTimes.removeFirst()
        }
    }
    
    private func addFPS(fps: Double) {
        self.fpsValues.append(fps)
        if self.fpsValues.count > self.maxDataPoints {
            self.fpsValues.removeFirst()
        }
    }
}

// MARK: - Delegate
extension YOLOViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame sampleBuffer: CMSampleBuffer) {
        predict(sampleBuffer: sampleBuffer)
    }
}
