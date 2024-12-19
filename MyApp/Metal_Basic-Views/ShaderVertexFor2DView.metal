//
//  ShaderVertexFor2DView.metal
//  MyApp
//
//  Created by Cong Le on 12/18/24.
//

/// Note: Set up to draw 2D view

#include <metal_stdlib>
using namespace metal;

struct ShaderVertexFor2DView {
  // [[position]] attribute is used to signify to Metal which value should be regarded as the clip-space position of the vertex returned by the vertex shader.
  // When returning a custom struct from a vertex shader, exactly one member of the struct must have this attribute. Alternatively, you may return a `float4` from your vertex function, which is implicitly assumed to be the vertex's position.
  float4 position [[position]];
  float4 color;
};

// The definition of Metal shader functions must be prefixed with a function qualifier: vertex, fragment, or kernel.
[[vertex]] ShaderVertexFor2DView main_vertex_for_2D_view(
  device ShaderVertexFor2DView const* const vertices [[buffer(0)]],
  uint vid [[vertex_id]]
) {
  return vertices[vid];
}

// [[stage_in]] attribute identifies it as per-fragment data rather than data that is constant accross a draw call.
// The Vertex here is an interpolated value.
[[fragment]] float4 main_fragment_for_2D_view(
  ShaderVertexFor2DView interpolatedVertex [[stage_in]]
) {
  return interpolatedVertex.color;
}
