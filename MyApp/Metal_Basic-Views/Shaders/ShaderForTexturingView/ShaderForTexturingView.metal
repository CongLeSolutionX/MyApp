//
//  ShaderForTexturingView.metal
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//
// Source: https://github.com/dehesa/sample-metal/blob/main/Metal%20By%20Example/Texturing/Shader.metal
//

#include <metal_stdlib>
using namespace metal;

// MARK: - Vertex shader

struct VertexInputForTexturingView {
  float4 position  [[attribute(0)]];
  float4 normal    [[attribute(1)]];
  float2 texCoords [[attribute(2)]];
};

struct UniformsForTexturingView {
  float4x4 modelViewProjectionMatrix;
  float4x4 modelViewMatrix;
  float3x3 normalMatrix;
};

struct VertexProjectedForTexturingView {
  float4 position [[position]];
  float3 eyePosition;
  float3 normal;
  float2 texCoords;
};

[[vertex]] VertexProjectedForTexturingView main_vertex_for_texturing_view(
  const VertexInputForTexturingView v [[stage_in]],
  constant UniformsForTexturingView& u [[buffer(1)]]
) {
  return VertexProjectedForTexturingView {
    .position = u.modelViewProjectionMatrix * v.position,
    .eyePosition = -(u.modelViewMatrix * v.position).xyz,
    .normal = u.normalMatrix * v.normal.xyz,
    .texCoords = v.texCoords
  };
}

// MARK: - Fragment shader

constant float3 kSpecularColor= { 1, 1, 1 };
constant float kSpecularPower = 80;

struct Light_ForTexturingView {
  float3 direction;
  float3 ambientColor;
  float3 diffuseColor;
  float3 specularColor;
};

constant Light_ForTexturingView light = {
  .direction     = { 0.13, 0.72, 0.68 },
  .ambientColor  = { 0.05, 0.05, 0.05 },
  .diffuseColor  = { 1, 1, 1 },
  .specularColor = { 0.2, 0.2, 0.2 }
};

[[fragment]] float4 main_fragment_for_texturing_view(
  VertexProjectedForTexturingView v [[stage_in]],
  texture2d<float> diffuseTexture [[texture(0)]],
  sampler samplr [[sampler(0)]]
) {
  float3 const diffuseColor = diffuseTexture.sample(samplr, v.texCoords).rgb;

  float3 const ambientTerm = light.ambientColor * diffuseColor;

  float3 const normal = normalize(v.normal);
  float const diffuseIntensity = saturate(dot(normal, light.direction));
  float3 const diffuseTerm = light.diffuseColor * diffuseColor * diffuseIntensity;

  float3 specularTerm(0);
  if (diffuseIntensity > 0) {
    float3 const eyeDirection = normalize(v.eyePosition);
    float3 const halfway = normalize(light.direction + eyeDirection);
    float specularFactor = pow(saturate(dot(normal, halfway)), kSpecularPower);
    specularTerm = light.specularColor * kSpecularColor * specularFactor;
  }

  return float4(ambientTerm + diffuseTerm + specularTerm, 1);
}
