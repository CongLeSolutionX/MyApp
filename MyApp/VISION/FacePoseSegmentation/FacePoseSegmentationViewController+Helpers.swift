//
//  FacePoseSegmentationViewController+Helpers.swift
//  MyApp
//
//  Created by Cong Le on 12/7/24.
//
/*
 Source: https://developer.apple.com/documentation/vision/applying-matte-effects-to-people-in-images-and-video
 
 Abstract:
 Supporting code for the FacePoseSegmentationViewController
 */

import MetalKit
import AVFoundation


extension FacePoseSegmentationViewController {
    
    func setupMetalKitView() {
        metalDevice = MTLCreateSystemDefaultDevice()
        metalCommandQueue = metalDevice?.makeCommandQueue()
        
        cameraView.device = metalDevice
        cameraView.delegate = self
        
        cameraView.isPaused = true
        cameraView.enableSetNeedsDisplay = false
        cameraView.framebufferOnly = false
    }
    
    func setupCoreImage() {
        ciContext = CIContext(mtlDevice: metalDevice)
    }
    
    func setupCaptureSession() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            fatalError("Error creating AVCaptureDevice")
        }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            fatalError("Error creating AVCaptureDeviceInput")
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.session = AVCaptureSession()
            strongSelf.session?.sessionPreset = .high
            strongSelf.session?.addInput(input)
            
            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(strongSelf, queue: .main)
            
            strongSelf.session?.addOutput(output)
            output.connections.first?.videoOrientation = .portrait
            strongSelf.session?.startRunning()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension FacePoseSegmentationViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    }
}

// MARK: - AngleColors
/// A structure that provides an RGB color intensity value for the roll, pitch, and yaw angles.
struct AngleColors {
    
    let red: CGFloat
    let blue: CGFloat
    let green: CGFloat
    
    init(roll: NSNumber?, pitch: NSNumber?, yaw: NSNumber?) {
        red = AngleColors.convert(value: roll, with: -.pi, and: .pi)
        blue = AngleColors.convert(value: pitch, with: -.pi / 2, and: .pi / 2)
        green = AngleColors.convert(value: yaw, with: -.pi / 2, and: .pi / 2)
    }
    
    static func convert(value: NSNumber?, with minValue: CGFloat, and maxValue: CGFloat) -> CGFloat {
        guard let value = value else { return 0 }
        let maxValue = maxValue * 0.8
        let minValue = minValue + (maxValue * 0.2)
        let facePoseRange = maxValue - minValue
        
        guard facePoseRange != 0 else { return 0 } // protect from zero division
        
        let colorRange: CGFloat = 1
        return (((CGFloat(truncating: value) - minValue) * colorRange) / facePoseRange)
    }
}
