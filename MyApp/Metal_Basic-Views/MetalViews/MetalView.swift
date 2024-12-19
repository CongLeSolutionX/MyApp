//
//  MetalView.swift
//  MyApp
//
//  Created by Cong Le on 12/17/24.
//


import SwiftUI
import Metal
import MetalKit

#if os(macOS)
// MARK: - A Plain Metal View
/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Clear%20Screen/MetalView.swift
/// Simple passthrough instance exposing the custom `NSView` containing the `CAMetalLayer`.
struct NSMetalPlainView: NSViewRepresentable {
  func makeNSView(context: Context) -> CAMetalPlainView {
    let device = MTLCreateSystemDefaultDevice()!
    let queue = device.makeCommandQueue()!.configure { $0.label = .identifier("queue")  }
    return CAMetalPlainView(device: device, queue: queue)
  }

  func updateNSView(_ lowlevelView: CAMetalPlainView, context: Context) {}
}
// MARK: - A Metal 2D View
/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Clear%20Screen/MetalView.swift
/// Simple passthrough instance exposing the custom `NSView` containing the `CAMetalLayer`.
struct NSMetal2DView: NSViewRepresentable {
  func makeNSView(context: Context) -> CAMetal2DView {
    let device = MTLCreateSystemDefaultDevice()!
    let queue = device.makeCommandQueue()!.configure { $0.label = .identifier("queue") }
    return CAMetal2DView(device: device, queue: queue)
  }

  func updateNSView(_ lowlevelView: CAMetal2DView, context: Context) {}
}

// MARK: - A 3D Metal View
/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Drawing%20in%203D/MetalView.swift
struct Metal3DView: NSViewRepresentable {
  /// Simple passthrough instance exposing the custom `NSView` containing the `CAMetalLayer`.
  func makeNSView(context: Context) -> CAMetal3DView {
    let renderer = context.coordinator
    return CAMetal3DView(device: renderer.device, renderer: renderer)
  }

  func updateNSView(_ lowlevelView: CAMetal3DView, context: Context) {}
}

// MARK: - A Metal View with Lighting
/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Lighting/MetalView.swift
struct MetalLightingView: NSViewRepresentable {
  func makeNSView(context: Context) -> MTKView {
    let renderer = context.coordinator
    return MTKView(frame: .zero, device: renderer.device).configure {
      $0.clearColor = MTLClearColorMake(0, 0, 0, 1)
      $0.colorPixelFormat = .bgra8Unorm
      $0.depthStencilPixelFormat = .depth32Float
      $0.delegate = renderer
    }
  }

  func updateNSView(_ lowlevelView: MTKView, context: Context) {}
}
// MARK: - A Metal View with Texture
/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Texturing/MetalView.swift
struct MetalTexturingView: NSViewRepresentable {
  func makeNSView(context: Context) -> MTKView {
    let renderer = context.coordinator
    return MTKView(frame: .zero, device: renderer.device).configure {
      $0.clearColor = MTLClearColorMake(0, 0, 0, 1)
      $0.colorPixelFormat = .bgra8Unorm
      $0.depthStencilPixelFormat = .depth32Float
      $0.delegate = renderer
    }
  }

  func updateNSView(_ lowlevelView: MTKView, context: Context) {}
}

#elseif canImport(UIKit)
// MARK: - A Metail Plain View
/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Clear%20Screen/MetalView.swift
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
/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Drawing%20in%202D/MetalView.swift
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
struct Metal3DView: UIViewRepresentable {
  func makeUIView(context: Context) -> CAMetal3DView {
    let renderer = context.coordinator
    return CAMetal3DView(device: renderer.device, renderer: renderer)
  }

  func updateUIView(_ lowlevelView: CAMetal3DView, context: Context) {}
}
// MARK: - A Metal View with Lighting
/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Lighting/MetalView.swift
struct MetalLightingView: UIViewRepresentable {
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


// MARK: - A Metal view with Texture
/// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Texturing/MetalView.swift
struct MetalTexturingView: UIViewRepresentable {
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

// MARK: - Extensions for Metal3DView
extension Metal3DView {
  @MainActor func makeCoordinator() -> CubeRenderer {
    let device = MTLCreateSystemDefaultDevice()!
    return CubeRenderer(device: device)!
  }
}

// MARK: - Extensions for MetalLightingView
extension MetalLightingView {
  @MainActor func makeCoordinator() -> TeapotRenderer {
    let device = MTLCreateSystemDefaultDevice()!
    return TeapotRenderer(device: device)!
  }
}

// MARK: - Extensions for MetalTexturingView
extension MetalTexturingView {
  @MainActor func makeCoordinator() -> CowRenderer {
    let device = MTLCreateSystemDefaultDevice()!
    return CowRenderer(device: device)!
  }
}
