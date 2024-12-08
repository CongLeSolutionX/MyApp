//
//  FacePoseSegmentationViewController.swift
//  MyApp
//
//  Created by Cong Le on 12/7/24.
//
/*
 Source: https://developer.apple.com/documentation/vision/applying-matte-effects-to-people-in-images-and-video
 
 Abstract:
 The sample app shows how to use Vision person segmentation and detect face
  to perform realtime image masking effects.
 */


import UIKit
import Vision
import AVFoundation
import MetalKit

final class FacePoseSegmentationViewController: UIViewController {
    
    // The Vision requests and the handler to perform them.
    private let requestHandler = VNSequenceRequestHandler()
    private var facePoseRequest: VNDetectFaceRectanglesRequest!
    private var segmentationRequest = VNGeneratePersonSegmentationRequest()
    
    // A structure that contains RGB color intensity values.
    private var colors: AngleColors?

    lazy var cameraView: MTKView = {
        let cameraView = MTKView()
        cameraView.device = MTLCreateSystemDefaultDevice()
        cameraView.clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
        cameraView.backgroundColor = .systemPink
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        guard metalDevice == nil else { return cameraView }

        // If the physical iPhone has metal device,
        // then proceed to setting up the MetalKitView
        setupMetalKitView()
        setupCoreImage()
        setupCaptureSession()
        return cameraView
    }()
    
    // The Metal pipeline.
    public var metalDevice: MTLDevice!
    public var metalCommandQueue: MTLCommandQueue!
    
    // The Core Image pipeline.
    public var ciContext: CIContext!
    public var currentCIImage: CIImage? {
        didSet {
            cameraView.draw()
        }
    }
    
    // The capture session that provides video frames.
    public var session: AVCaptureSession?
    
    // MARK: - ViewController LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        intializeRequests()
        view.backgroundColor = .systemGreen
        view.addSubview(cameraView)
        
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    deinit {
        session?.stopRunning()
    }
    
    // MARK: - Prepare Requests
    
    private func intializeRequests() {
        
        // Create a request to detect face rectangles.
        facePoseRequest = VNDetectFaceRectanglesRequest { [weak self] request, _ in
            guard let face = request.results?.first as? VNFaceObservation else { return }
            // Generate RGB color intensity values for the face rectangle angles.
            self?.colors = AngleColors(roll: face.roll, pitch: face.pitch, yaw: face.yaw)
        }
        facePoseRequest.revision = VNDetectFaceRectanglesRequestRevision3
        
        // Create a request to segment a person from an image.
        segmentationRequest = VNGeneratePersonSegmentationRequest()
        segmentationRequest.qualityLevel = .balanced
        segmentationRequest.outputPixelFormat = kCVPixelFormatType_OneComponent8
    }
    
    // MARK: - Perform Requests
    
    private func processVideoFrame(_ framePixelBuffer: CVPixelBuffer) {
        // Perform the requests on the pixel buffer that contains the video frame.
        try? requestHandler.perform([facePoseRequest, segmentationRequest],
                                    on: framePixelBuffer,
                                    orientation: .right)
        
        // Get the pixel buffer that contains the mask image.
        guard let maskPixelBuffer =
                segmentationRequest.results?.first?.pixelBuffer else { return }
        
        // Process the images.
        blend(original: framePixelBuffer, mask: maskPixelBuffer)
    }
    
    // MARK: - Process Results
    
    // Performs the blend operation.
    private func blend(original framePixelBuffer: CVPixelBuffer,
                       mask maskPixelBuffer: CVPixelBuffer) {
        
        // Remove the optionality from generated color intensities or exit early.
        guard let colors = colors else { return }
        
        // Create CIImage objects for the video frame and the segmentation mask.
        let originalImage = CIImage(cvPixelBuffer: framePixelBuffer).oriented(.right)
        var maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
        
        // Scale the mask image to fit the bounds of the video frame.
        let scaleX = originalImage.extent.width / maskImage.extent.width
        let scaleY = originalImage.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
        
        // Define RGB vectors for CIColorMatrix filter.
        let vectors = [
            "inputRVector": CIVector(x: 0, y: 0, z: 0, w: colors.red),
            "inputGVector": CIVector(x: 0, y: 0, z: 0, w: colors.green),
            "inputBVector": CIVector(x: 0, y: 0, z: 0, w: colors.blue)
        ]
        
        // Create a colored background image.
        let backgroundImage = maskImage.applyingFilter("CIColorMatrix",
                                                       parameters: vectors)
        
        // Blend the original, background, and mask images.
        let blendFilter = CIFilter.blendWithRedMask()
        blendFilter.inputImage = originalImage
        blendFilter.backgroundImage = backgroundImage
        blendFilter.maskImage = maskImage
        
        // Set the new, blended image as current.
        currentCIImage = blendFilter.outputImage?.oriented(.left)
    }
}
