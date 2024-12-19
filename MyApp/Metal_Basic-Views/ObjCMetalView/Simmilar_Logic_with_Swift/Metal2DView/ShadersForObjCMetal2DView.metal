//
//  ShadersForObjCMetal2DView.metal
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

#include <metal_stdlib>
using namespace metal;

struct VertexForObjCMetal2DView {
    float2 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};
// MARK: - White color
//vertex float4 vertexShader(
//    uint vertexID [[vertex_id]],
//    constant Vertex *vertices [[buffer(0)]]) {
//    return float4(vertices[vertexID].position, 0.0, 1.0);
//}
//
//fragment half4 fragmentShader() {
//    return half4(1.0); // White color
//}

// MARK: - Colorful
struct VertexOutForObjCMetal2DView {
    float4 position [[position]];
    float4 color;
};

vertex VertexOutForObjCMetal2DView vertex_shader_for_2D_view(
    uint vertexID [[vertex_id]],
    constant VertexForObjCMetal2DView *vertices [[buffer(0)]]) {
    VertexOutForObjCMetal2DView out;
    out.position = float4(vertices[vertexID].position, 0.0, 1.0);
    out.color = vertices[vertexID].color;
    return out;
}

fragment half4 fragment_shader_for_2d_view(VertexOutForObjCMetal2DView in [[stage_in]]) {
    return half4(in.color);
}
