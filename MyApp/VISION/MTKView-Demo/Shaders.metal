//
//  Shaders.metal
//  MyApp
//
//  Created by Cong Le on 12/7/24.
//

// Shaders.metal

#include <metal_stdlib>
using namespace metal;

// Vertex structure
struct VertexIn {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

// Vertex output structure
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

// Vertex shader
vertex VertexOut vertex_passthrough(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = in.position;
    out.texCoord = in.texCoord;
    return out;
}

// Fragment shader
fragment float4 fragment_passthrough(VertexOut in [[stage_in]],
                                     texture2d<float> texture [[texture(0)]],
                                     sampler textureSampler [[sampler(0)]]) {
    return texture.sample(textureSampler, in.texCoord);
}
