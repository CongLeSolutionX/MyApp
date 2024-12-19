//
//  Shaders.metal
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

vertex float4 vertexShader(
    uint vertexID [[vertex_id]],
    constant Vertex *vertices [[buffer(0)]]) {
    return float4(vertices[vertexID].position, 0.0, 1.0);
}

fragment half4 fragmentShader() {
    return half4(1.0); // White color
}
