//
//  Shaders.metal
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//
#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float3 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct Uniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

vertex float4 vertexShader(const device Vertex *vertices [[buffer(0)]],
                           uint vertexID [[vertex_id]],
                           constant Uniforms &uniforms [[buffer(1)]]) {
    Vertex in = vertices[vertexID];
    float4 position = float4(in.position, 1.0);
    float4 worldPosition = uniforms.modelMatrix * position;
    float4 viewPosition = uniforms.viewMatrix * worldPosition;
    float4 clipPosition = uniforms.projectionMatrix * viewPosition;
    return clipPosition;
}

fragment float4 fragmentShader() {
    return float4(1, 0, 0, 1); // Red color
}
