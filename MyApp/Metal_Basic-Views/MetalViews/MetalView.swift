//
//  MetalView.swift
//  MyApp
//
//  Created by Cong Le on 12/17/24.
//
// Source: https://github.com/dehesa/sample-metal/tree/main/Metal%20By%20Example/Clear%20Screen

import SwiftUI
import Metal

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
/// Simple passthrough instance exposing the custom `UIView` containing the `CAMetalLayer`.
struct iOS_UIKit_MetalPlainView: UIViewRepresentable {
  func makeUIView(context: Context) -> CAMetalPlainView {
    let device = MTLCreateSystemDefaultDevice()!
    let queue = device.makeCommandQueue()!.configure { $0.label = .identifier("queue") }
    return CAMetalPlainView(device: device, queue: queue)
  }

  func updateUIView(_ lowlevelView: CAMetalPlainView, context: Context) {}
}
/// Simple passthrough instance exposing the custom `UIView` containing the `CAMetalLayer`.
struct iOS_UIKit_Metal2DView: UIViewRepresentable {
  func makeUIView(context: Context) -> CAMetal2DView {
    let device = MTLCreateSystemDefaultDevice()!
    let queue = device.makeCommandQueue()!.configure { $0.label = .identifier("queue") }
    return CAMetal2DView(device: device, queue: queue)
  }

  func updateUIView(_ lowlevelView: CAMetal2DView, context: Context) {}
}

/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Drawing%20in%203D/MetalView.swift
/// Simple passthrough instance exposing the custom `UIView` containing the `CAMetalLayer`.
struct iOS_UIKit_Metal3DView: UIViewRepresentable {
  func makeUIView(context: Context) -> CAMetal3DView {
    let renderer = context.coordinator
    return CAMetal3DView(device: renderer.device, renderer: renderer)
  }

  func updateUIView(_ lowlevelView: CAMetal3DView, context: Context) {}
}
#endif

// MARK: - Extensions for iOS_UIKit_Metal3DView
extension iOS_UIKit_Metal3DView {
  @MainActor func makeCoordinator() -> CubeRenderer {
    let device = MTLCreateSystemDefaultDevice()!
    return CubeRenderer(device: device)!
  }
}
