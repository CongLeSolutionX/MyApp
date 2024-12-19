//
//  ShaderFor3DView.metal
//  MyApp
//
//  Created by Cong Le on 12/18/24.
//

#include <metal_stdlib>
using namespace metal;

struct ShaderVertexFor3DView {
  float4 position [[position]];
  float4 color;
};

struct ShaderUniformsFor3DView {
  float4x4 mvpMatrix;
};

[[vertex]] ShaderVertexFor3DView main_vertex_for_3D_view(
 device ShaderVertexFor3DView const* const vertices [[buffer(0)]],
 constant ShaderUniformsFor3DView* uniforms [[buffer(1)]],
 uint vid [[vertex_id]]
) {
  return ShaderVertexFor3DView {
    .position = uniforms->mvpMatrix * vertices[vid].position,
    .color = vertices[vid].color
  };
}

[[fragment]] float4 main_fragment_for_3D_view(
ShaderVertexFor3DView interpolatedVertex [[stage_in]]
) {
  return interpolatedVertex.color;
}
