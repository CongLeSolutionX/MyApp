//
//  MetalRendererViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/23/24.
//

#if os(macOS)
import Cocoa
/// Typealias for platform-specific view controller
typealias PlatformViewController = NSViewController
#else
import UIKit
/// Typealias for platform-specific view controller
typealias PlatformViewController = UIViewController
#endif

import MetalKit
//import SwiftUICore

/// The `MetalRendererViewController` class manages the Metal rendering view and renderer setup.
/// It handles initialization and configuration of the `MTKView` and `Renderer`,
/// and responds to user interactions for rendering options.
class MetalRendererViewController: PlatformViewController {

    /// The renderer responsible for rendering content using Metal.
    private var renderer: Renderer?

    /// The MetalKit view used for rendering.
    private var mtkView: MTKView!

    #if os(iOS)
    /// Slider to adjust transparency.
    private var transparencySlider: UISlider?

    /// Segmented control to select blend mode.
    private var blendModeControl: UISegmentedControl?
    #endif
    
    /// Called when the view controller's view is loaded into memory.
    override func loadView() {
        // Create and configure the MTKView.
        mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        
        #if os(iOS) || os(tvOS)
        // Set the background color for iOS and tvOS.
        mtkView.backgroundColor = UIColor.black
        #endif

        // Assign the MTKView to the view controller's view.
        self.view = mtkView
    }


    /// Called after the view controller's view has been loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Ensure the view is an MTKView.
        guard let mtkView = self.view as? MTKView else {
            print("View of ViewController is not an MTKView")
            return
        }
        self.mtkView = mtkView

        // Set the Metal device to the default device.
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        mtkView.device = defaultDevice

        #if os(iOS) || os(tvOS)
        // Set the background color for iOS and tvOS.
        mtkView.backgroundColor = UIColor.black
        #endif

        // Initialize the renderer with the MetalKit view.
        guard let renderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }
        self.renderer = renderer

        // Configure the renderer.
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        renderer.blendMode = .transparency
        renderer.transparency = 0.5

        // Assign the renderer as the delegate for the MTKView.
        mtkView.delegate = renderer

        #if os(iOS)
        // Set up UI elements programmatically.
        setupUIElements()
        #endif
    }

    #if os(iOS)
    /// Sets up the UI elements programmatically.
    private func setupUIElements() {
        // Create and configure the blend mode control.
        let blendModeControl = UISegmentedControl(items: ["Normal", "Additive", "Transparency"])
        blendModeControl.selectedSegmentIndex = 0
        blendModeControl.addTarget(self, action: #selector(blendModeChanged(_:)), for: .valueChanged)
        blendModeControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(blendModeControl)
        self.blendModeControl = blendModeControl

        // Create and configure the transparency slider.
        let transparencySlider = UISlider()
        transparencySlider.minimumValue = 0.0
        transparencySlider.maximumValue = 1.0
        transparencySlider.value = renderer?.transparency ?? 0.5
        transparencySlider.isHidden = true // Initially hidden unless transparency blend mode is selected.
        transparencySlider.addTarget(self, action: #selector(transparencyChanged(_:)), for: .valueChanged)
        transparencySlider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(transparencySlider)
        self.transparencySlider = transparencySlider

        // Layout constraints.
        NSLayoutConstraint.activate([
            // Position blendModeControl at the bottom of the view.
            blendModeControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            blendModeControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            blendModeControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            // Position transparencySlider just above blendModeControl.
            transparencySlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            transparencySlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            transparencySlider.bottomAnchor.constraint(equalTo: blendModeControl.topAnchor, constant: -20)
        ])
    }

    /// Action method called when the blend mode changes.
    /// - Parameter sender: The segmented control that triggered the action.
    @objc func blendModeChanged(_ sender: UISegmentedControl) {
        // Update the blend mode based on the selected segment.
        guard let selectedBlendMode = BlendMode(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        renderer?.blendMode = selectedBlendMode

        // Show or hide the transparency slider based on the blend mode.
        transparencySlider?.isHidden = selectedBlendMode != .transparency
    }

    /// Action method called when the transparency value changes.
    /// - Parameter sender: The slider that triggered the action.
    @objc func transparencyChanged(_ sender: UISlider) {
        // Update the renderer's transparency value.
        renderer?.transparency = sender.value
    }
    #endif
}
