//
//  TessellationMetalView.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/dehesa/sample-metal

import SwiftUI
import MetalKit

#if os(macOS)
struct TessellationMetalViewMetalView: NSViewRepresentable {
  let patchType: MTLPatchType
  let edgeFactor: Float
  let insideFactor: Float
  let isWireframe: Bool

  func makeNSView(context: Context) -> MTKView {
    let view = MTKView()
    view.device = context.coordinator.device
    view.delegate = context.coordinator
    return view
  }

  func updateNSView(_ view: MTKView, context: Context) {
    context.coordinator.patchType = self.patchType
    context.coordinator.wireframe = self.isWireframe
    context.coordinator.factors.edge = self.edgeFactor
    context.coordinator.factors.inside = self.insideFactor
  }
}
#elseif canImport(UIKit)
struct TessellationMetalView: UIViewRepresentable {
  let patchType: MTLPatchType
  let edgeFactor: Float
  let insideFactor: Float
  let isWireframe: Bool

  func makeUIView(context: Context) -> MTKView {
    let view = MTKView()
    view.device = context.coordinator.device
    view.delegate = context.coordinator
    return view
  }

  func updateUIView(_ view: MTKView, context: Context) {
    context.coordinator.patchType = self.patchType
    context.coordinator.wireframe = self.isWireframe
    context.coordinator.factors.edge = self.edgeFactor
    context.coordinator.factors.inside = self.insideFactor
  }
}
#endif

extension TessellationMetalView {
  @MainActor func makeCoordinator() -> TessellationRenderer {
    TessellationRenderer()
  }

  static var maxTessellationFactor: Int {
    #if os(macOS)
    64
    #else
    16
    #endif
  }
}
