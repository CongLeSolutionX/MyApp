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
  func makeNSView(context: Context) -> CAMetalView {
    let device = MTLCreateSystemDefaultDevice()!
    let queue = device.makeCommandQueue()!.configure { $0.label = .identifier("queue")  }
    return CAMetalView(device: device, queue: queue)
  }

  func updateNSView(_ lowlevelView: CAMetalView, context: Context) {}
}
#elseif canImport(UIKit)
/// Simple passthrough instance exposing the custom `UIView` containing the `CAMetalLayer`.
struct iOS_UIKit_MetalView: UIViewRepresentable {
  func makeUIView(context: Context) -> CAMetalView {
    let device = MTLCreateSystemDefaultDevice()!
    let queue = device.makeCommandQueue()!.configure { $0.label = .identifier("queue") }
    return CAMetalView(device: device, queue: queue)
  }

  func updateUIView(_ lowlevelView: CAMetalView, context: Context) {}
}

struct iOS_UIKit_Metal2DView: UIViewRepresentable {
  func makeUIView(context: Context) -> CAMetal2DView {
    let device = MTLCreateSystemDefaultDevice()!
    let queue = device.makeCommandQueue()!.configure { $0.label = .identifier("queue") }
    return CAMetal2DView(device: device, queue: queue)
  }

  func updateUIView(_ lowlevelView: CAMetal2DView, context: Context) {}
}
#endif
