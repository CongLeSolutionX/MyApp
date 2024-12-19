//
//  ShaderForTexturingView.swift
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

import simd

/// The vertices being fed to the GPU.
struct ShaderVertexForTexturingView {
  var position: SIMD4<Float>
  var normal: SIMD4<Float>
  var texCoords: SIMD2<Float>
}

struct ShaderUniformsForTexturingView {
  var modelViewProjectionMatrix: float4x4
  var modelViewMatrix: float4x4
  var normalMatrix: float3x3
}
