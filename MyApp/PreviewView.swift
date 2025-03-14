//
//  PreviewView.swift
//  MyApp
//
//  Created by Cong Le on 3/14/25.
//

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The preview view for the app.
*/

import UIKit
import AVFoundation

class PreviewView: UIView, UIGestureRecognizerDelegate {

    // MARK: - Types

    private enum ControlCorner {
        case none, topLeft, topRight, bottomLeft, bottomRight
    }
    
    // MARK: - Properties

    // Controls for region of interest
    private let regionOfInterestCornerTouchThreshold: CGFloat = 50
    private var minimumRegionOfInterestSize: CGFloat { regionOfInterestCornerTouchThreshold }
    private let regionOfInterestControlDiameter: CGFloat = 12.0
    private var regionOfInterestControlRadius: CGFloat { regionOfInterestControlDiameter / 2.0 }
    
    private let maskLayer = CAShapeLayer()
    private let regionOfInterestOutline = CAShapeLayer()
    
    private let topLeftControl = CAShapeLayer()
    private let topRightControl = CAShapeLayer()
    private let bottomLeftControl = CAShapeLayer()
    private let bottomRightControl = CAShapeLayer()
    
    // The current control corner that is used during resizing.
    private var currentControlCorner: ControlCorner = .none

    /// The region of interest (ROI) rectangle.
    @objc private(set) dynamic var regionOfInterest = CGRect.null

    // Gesture recognizer for resizing/moving the ROI.
    private lazy var resizeRegionOfInterestGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(resizeRegionOfInterestWithGestureRecognizer(_:)))
        pan.delegate = self
        return pan
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        // Configure mask layer.
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.opacity = 0.6
        layer.addSublayer(maskLayer)
        
        // Configure ROI outline.
        regionOfInterestOutline.path = UIBezierPath(rect: regionOfInterest).cgPath
        regionOfInterestOutline.fillColor = UIColor.clear.cgColor
        regionOfInterestOutline.strokeColor = UIColor.yellow.cgColor
        layer.addSublayer(regionOfInterestOutline)
        
        // Create the ROI controls.
        let controlRect = CGRect(x: 0, y: 0, width: regionOfInterestControlDiameter, height: regionOfInterestControlDiameter)
        for control in [topLeftControl, topRightControl, bottomLeftControl, bottomRightControl] {
            control.path = UIBezierPath(ovalIn: controlRect).cgPath
            control.fillColor = UIColor.white.cgColor
            layer.addSublayer(control)
        }
        
        addGestureRecognizer(resizeRegionOfInterestGestureRecognizer)
    }
    
    // MARK: - AV Capture Properties

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected AVCaptureVideoPreviewLayer type. Check PreviewView.layerClass implementation.")
        }
        return layer
    }
    
    var session: AVCaptureSession? {
        get { videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }
    
    // MARK: - Region of Interest Methods

    /// Update the ROI ensuring it remains inside video preview bounds and honors minimum sizes.
    func setRegionOfInterestWithProposedRegionOfInterest(_ proposedROI: CGRect) {
        let videoPreviewRect = videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: CGRect(x: 0, y: 0, width: 1, height: 1)).standardized
        let visiblePreviewRect = videoPreviewRect.intersection(frame)
        let oldROI = regionOfInterest
        var newROI = proposedROI.standardized
        
        // If not resizing using a corner, then move ROI inside the visible bounds.
        if currentControlCorner == .none {
            var xOffset: CGFloat = 0, yOffset: CGFloat = 0
            if !visiblePreviewRect.contains(newROI.origin) {
                xOffset = max(visiblePreviewRect.minX - newROI.minX, 0)
                yOffset = max(visiblePreviewRect.minY - newROI.minY, 0)
            }
            
            if !visiblePreviewRect.contains(CGPoint(x: visiblePreviewRect.maxX, y: visiblePreviewRect.maxY)) {
                xOffset = min(visiblePreviewRect.maxX - newROI.maxX, xOffset)
                yOffset = min(visiblePreviewRect.maxY - newROI.maxY, yOffset)
            }
            newROI = newROI.offsetBy(dx: xOffset, dy: yOffset)
        }
        
        // Clamp ROI within bounds.
        newROI = visiblePreviewRect.intersection(newROI)
        
        // Enforce minimum width.
        if proposedROI.size.width < minimumRegionOfInterestSize {
            switch currentControlCorner {
            case .topLeft, .bottomLeft:
                newROI.origin.x = oldROI.origin.x + oldROI.size.width - minimumRegionOfInterestSize
                newROI.size.width = minimumRegionOfInterestSize
            case .topRight:
                newROI.origin.x = oldROI.origin.x
                newROI.size.width = minimumRegionOfInterestSize
            default:
                newROI.origin = oldROI.origin
                newROI.size.width = minimumRegionOfInterestSize
            }
        }
        
        // Enforce minimum height.
        if proposedROI.size.height < minimumRegionOfInterestSize {
            switch currentControlCorner {
            case .topLeft, .topRight:
                newROI.origin.y = oldROI.origin.y + oldROI.size.height - minimumRegionOfInterestSize
                newROI.size.height = minimumRegionOfInterestSize
            case .bottomLeft:
                newROI.origin.y = oldROI.origin.y
                newROI.size.height = minimumRegionOfInterestSize
            default:
                newROI.origin = oldROI.origin
                newROI.size.height = minimumRegionOfInterestSize
            }
        }
        
        regionOfInterest = newROI
        setNeedsLayout()
    }
    
    var isResizingRegionOfInterest: Bool {
        return resizeRegionOfInterestGestureRecognizer.state == .changed
    }
    
    @objc
    func resizeRegionOfInterestWithGestureRecognizer(_ panGR: UIPanGestureRecognizer) {
        guard let viewForGesture = panGR.view else { return }
        let touchLocation = panGR.location(in: viewForGesture)
        let oldROI = regionOfInterest
        
        switch panGR.state {
        case .began:
            currentControlCorner = cornerOfRect(oldROI, closestToPointWithinTouchThreshold: touchLocation)
        case .changed:
            willChangeValue(forKey: "regionOfInterest")
            var newROI = oldROI
            
            switch currentControlCorner {
            case .none:
                let translation = panGR.translation(in: viewForGesture)
                // Move ROI if touch is inside.
                if regionOfInterest.contains(touchLocation) {
                    newROI.origin.x += translation.x
                    newROI.origin.y += translation.y
                }
                // Restrict translation if touch is outside preview bounds.
                let normalizedRect = CGRect(x: 0, y: 0, width: 1, height: 1)
                if !normalizedRect.contains(videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchLocation)) {
                    if touchLocation.x < regionOfInterest.minX || touchLocation.x > regionOfInterest.maxX {
                        newROI.origin.y += translation.y
                    } else if touchLocation.y < regionOfInterest.minY || touchLocation.y > regionOfInterest.maxY {
                        newROI.origin.x += translation.x
                    }
                }
                panGR.setTranslation(.zero, in: viewForGesture)
                
            case .topLeft:
                newROI = CGRect(x: touchLocation.x,
                                y: touchLocation.y,
                                width: oldROI.size.width + oldROI.origin.x - touchLocation.x,
                                height: oldROI.size.height + oldROI.origin.y - touchLocation.y)
            case .topRight:
                newROI = CGRect(x: oldROI.origin.x,
                                y: touchLocation.y,
                                width: touchLocation.x - oldROI.origin.x,
                                height: oldROI.size.height + oldROI.origin.y - touchLocation.y)
            case .bottomLeft:
                newROI = CGRect(x: touchLocation.x,
                                y: oldROI.origin.y,
                                width: oldROI.size.width + oldROI.origin.x - touchLocation.x,
                                height: touchLocation.y - oldROI.origin.y)
            case .bottomRight:
                newROI = CGRect(x: oldROI.origin.x,
                                y: oldROI.origin.y,
                                width: touchLocation.x - oldROI.origin.x,
                                height: touchLocation.y - oldROI.origin.y)
            }
            
            self.setRegionOfInterestWithProposedRegionOfInterest(newROI)
            didChangeValue(forKey: "regionOfInterest")
            
        case .ended, .cancelled, .failed:
            currentControlCorner = .none
        default:
            break
        }
    }
    
    private func cornerOfRect(_ rect: CGRect, closestToPointWithinTouchThreshold point: CGPoint) -> ControlCorner {
        var closestDistance = CGFloat.greatestFiniteMagnitude
        var closestCorner: ControlCorner = .none
        let corners: [(ControlCorner, CGPoint)] = [
            (.topLeft, rect.origin),
            (.topRight, CGPoint(x: rect.maxX, y: rect.minY)),
            (.bottomLeft, CGPoint(x: rect.minX, y: rect.maxY)),
            (.bottomRight, CGPoint(x: rect.maxX, y: rect.maxY))
        ]
        
        for (corner, pt) in corners {
            let distance = hypot(point.x - pt.x, point.y - pt.y)
            if distance < closestDistance {
                closestDistance = distance
                closestCorner = corner
            }
        }
        return closestDistance > regionOfInterestCornerTouchThreshold ? .none : closestCorner
    }
    
    // MARK: - UIView Overrides
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Create mask path that uses the even-odd rule.
        let outerPath = UIBezierPath(rect: bounds)
        outerPath.append(UIBezierPath(rect: regionOfInterest))
        outerPath.usesEvenOddFillRule = true
        maskLayer.path = outerPath.cgPath
        
        regionOfInterestOutline.path = UIBezierPath(rect: regionOfInterest).cgPath
        
        let left = regionOfInterest.origin.x - regionOfInterestControlRadius
        let right = regionOfInterest.origin.x + regionOfInterest.size.width - regionOfInterestControlRadius
        let top = regionOfInterest.origin.y - regionOfInterestControlRadius
        let bottom = regionOfInterest.origin.y + regionOfInterest.size.height - regionOfInterestControlRadius
        
        topLeftControl.position = CGPoint(x: left, y: top)
        topRightControl.position = CGPoint(x: right, y: top)
        bottomLeftControl.position = CGPoint(x: left, y: bottom)
        bottomRightControl.position = CGPoint(x: right, y: bottom)
        
        CATransaction.commit()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == resizeRegionOfInterestGestureRecognizer {
            let touchLocation = touch.location(in: gestureRecognizer.view)
            let paddedROI = regionOfInterest.insetBy(dx: -regionOfInterestCornerTouchThreshold, dy: -regionOfInterestCornerTouchThreshold)
            return paddedROI.contains(touchLocation)
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == resizeRegionOfInterestGestureRecognizer {
            let touchLocation = gestureRecognizer.location(in: gestureRecognizer.view)
            let closestCorner = cornerOfRect(regionOfInterest, closestToPointWithinTouchThreshold: touchLocation)
            return closestCorner == .none
        }
        return false
    }
}
