//
//  Shaders.metal
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//
// SSource: https://github.com/metal-by-example/sample-code/blob/master/objc/04-DrawingIn3D/DrawingIn3D/Shaders.metal

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelViewProjectionMatrix;
};

vertex Vertex vertex_project(const device Vertex *vertices [[buffer(0)]],
                             constant Uniforms &uniforms   [[buffer(1)]],
                             uint vid [[vertex_id]]) {
    Vertex vertexOut;
    vertexOut.position = uniforms.modelViewProjectionMatrix * vertices[vid].position;
    vertexOut.color = vertices[vid].color;
    return vertexOut;
}

fragment half4 fragment_flatcolor(Vertex in [[stage_in]]) {
    return half4(in.color);
}