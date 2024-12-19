//
//  MetalView.swift
//  MyApp
//
//  Created by Cong Le on 12/17/24.
//
// Source: https://github.com/dehesa/sample-metal/tree/main/Metal%20By%20Example/Clear%20Screen

import SwiftUI
import Metal
import MetalKit

#if os(macOS)
/// Simple passthrough instance exposing the custom `NSView` containing the `CAMetalLayer`.
struct NSMetalView: NSViewRepresentable {
  func makeNSView(context: Context) -> CAMetalPlainView {
    let device = MTLCreateSystemDefaultDevice()!
    let queue = device.makeCommandQueue()!.configure { $0.label = .identifier("queue")  }
    return CAMetalPlainView(device: device, queue: queue)
  }

  func updateNSView(_ lowlevelView: CAMetalPlainView, context: Context) {}
}
#elseif canImport(UIKit)
// MARK: - A Metail Plain View
/// Simple passthrough instance exposing the custom `UIView` containing the `CAMetalLayer`.
struct iOS_UIKit_MetalPlainView: UIViewRepresentable {
  func makeUIView(context: Context) -> CAMetalPlainView {
    let device = MTLCreateSystemDefaultDevice()!
    let queue = device.makeCommandQueue()!.configure { $0.label = .identifier("queue") }
    return CAMetalPlainView(device: device, queue: queue)
  }

  func updateUIView(_ lowlevelView: CAMetalPlainView, context: Context) {}
}
// MARK: - A 2D Metal View
/// Simple passthrough instance exposing the custom `UIView` containing the `CAMetalLayer`.
struct iOS_UIKit_Metal2DView: UIViewRepresentable {
  func makeUIView(context: Context) -> CAMetal2DView {
    let device = MTLCreateSystemDefaultDevice()!
    let queue = device.makeCommandQueue()!.configure { $0.label = .identifier("queue") }
    return CAMetal2DView(device: device, queue: queue)
  }

  func updateUIView(_ lowlevelView: CAMetal2DView, context: Context) {}
}
// MARK: - A 3D Metal View
/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Drawing%20in%203D/MetalView.swift
/// Simple passthrough instance exposing the custom `UIView` containing the `CAMetalLayer`.
struct iOS_UIKit_Metal3DView: UIViewRepresentable {
  func makeUIView(context: Context) -> CAMetal3DView {
    let renderer = context.coordinator
    return CAMetal3DView(device: renderer.device, renderer: renderer)
  }

  func updateUIView(_ lowlevelView: CAMetal3DView, context: Context) {}
}
// MARK: -
struct iOS_UIKit_MetalLightingView: UIViewRepresentable {
  func makeUIView(context: Context) -> MTKView {
    let renderer = context.coordinator
    return MTKView(frame: .zero, device: renderer.device).configure {
      $0.clearColor = MTLClearColorMake(0, 0, 0, 1)
      $0.colorPixelFormat = .bgra8Unorm
      $0.depthStencilPixelFormat = .depth32Float
      $0.delegate = renderer
    }
  }

  func updateUIView(_ lowlevelView: MTKView, context: Context) {}
}

#endif

// MARK: - Extensions for iOS_UIKit_Metal3DView
extension iOS_UIKit_Metal3DView {
  @MainActor func makeCoordinator() -> CubeRenderer {
    let device = MTLCreateSystemDefaultDevice()!
    return CubeRenderer(device: device)!
  }
}

// MARK: - Extensions for iOS_UIKit_MetalLightingView
extension iOS_UIKit_MetalLightingView {
  @MainActor func makeCoordinator() -> TeapotRenderer {
    let device = MTLCreateSystemDefaultDevice()!
    return TeapotRenderer(device: device)!
  }
}
