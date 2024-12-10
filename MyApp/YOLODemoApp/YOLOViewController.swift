// ViewController.swift

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

    let selection = UISelectionFeedbackGenerator()
    var detector = try! VNCoreMLModel(for: mlModel)
    var session: AVCaptureSession!
    //var videoCapture: VideoCapture!
    //var currentBuffer: CVPixelBuffer?
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
   // var boundingBoxViews = [BoundingBoxView]()
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
        //setUpBoundingBoxViews()
        //startVideo()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        videoPreview.frame = view.bounds
        //videoCapture.previewLayer?.frame = videoPreview.bounds
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
        overlayView.backgroundColor = .red
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
            segmentedControl.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
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

//        for view in labelsAndSliders {
//            overlayView.addSubview(view)
//            NSLayoutConstraint.activate([
//                view.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 20),
//                view.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -20),
//                view.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 10),
//            ])
//            previousView = view
//        }

        // Gesture Recognizer for Pinch to Zoom
        //let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        //videoPreview.addGestureRecognizer(pinchGesture)
    }

    private func createLabel(fontSize: CGFloat, weight: UIFont.Weight = .regular) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(label)
        return label
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
        //setUpBoundingBoxViews()
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
        //self.videoCapture.start()
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

    // Implement other methods such as startVideo(), setUpBoundingBoxViews(), processObservations(), predict(), show(), etc.

    // Remember to collect inference time and FPS for statistics
    func processObservations(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
//            if let results = request.results as? [VNRecognizedObjectObservation] {
//                self.show(predictions: results)
//            } else {
//                self.show(predictions: [])
//            }

            // Measure FPS
            if self.t1 < 10.0 {  // valid dt
                self.t2 = self.t1 * 0.05 + self.t2 * 0.95  // smoothed inference time
            }
            self.t4 = (CACurrentMediaTime() - self.t3) * 0.05 + self.t4 * 0.95  // smoothed delivered FPS
            self.labelFPS.text = String(format: "%.1f FPS - %.1f ms", 1 / self.t4, self.t2 * 1000)  // t2 seconds to ms
            self.t3 = CACurrentMediaTime()

            // Collect inference time and FPS
            self.addInferenceTime(time: self.t2)
            self.addFPS(fps: 1 / self.t4)
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

    // Implement pinch to zoom method and other necessary methods.

    // ...
}
