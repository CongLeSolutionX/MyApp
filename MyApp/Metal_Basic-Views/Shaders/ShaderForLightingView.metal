//
//  ShaderForLightingView.metal
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

#include <metal_stdlib>
#include <metal_matrix>
using namespace metal;

struct VertexInputForLightingView {
  float4 position [[attribute(0)]];
  float4 normal   [[attribute(1)]];
};

struct ShaderUniformsForLightingView {
  float4x4 mvpMatrix;
  float4x4 mvMatrix;
  float3x3 normalMatrix;
};

struct VertexProjectedForLightingView {
  float4 position [[position]];
  float3 eye;
  float3 normal;
};

[[vertex]] VertexProjectedForLightingView main_vertex_for_lighting_view(
  const    VertexInputForLightingView     v [[stage_in]],
  constant ShaderUniformsForLightingView& u [[buffer(1)]]
) {
  return VertexProjectedForLightingView{
    .position = u.mvpMatrix * v.position,
    .eye = -(u.mvMatrix * v.position).xyz,
    .normal = u.normalMatrix * v.normal.xyz
  };
}

// MARK: -

struct Light {
  float3 direction;
  float3 ambientColor;
  float3 diffuseColor;
  float3 specularColor;
};

struct Material {
  float3 ambientColor;
  float3 diffuseColor;
  float3 specularColor;
  float specularPower;
};

constant Light light = {
  .direction = { 0.13, 0.72, 0.68 },
  .ambientColor = { 0.05, 0.05, 0.05 },
  .diffuseColor = { 0.9, 0.9, 0.9 },
  .specularColor = { 1, 1, 1 }
};

constant Material material = {
  .ambientColor = { 0.9, 0.1, 0 },
  .diffuseColor = { 0.9, 0.1, 0 },
  .specularColor = { 1, 1, 1 },
  .specularPower = 100
};

[[fragment]] float4 main_fragment_for_lighting_view(
  const VertexProjectedForLightingView v [[stage_in]]
) {
  float3 const ambient = light.ambientColor * material.ambientColor;

  float3 const normal = normalize(v.normal);
  float const intensityDiffuse = saturate(dot(normal, light.direction));  // `saturate` clamps the value between 0 and 1.
  float3 const diffuse = intensityDiffuse * (light.diffuseColor * material.diffuseColor);

  float3 specular(0);
  if (intensityDiffuse > 0) {
    float3 const eyeDirection = normalize(v.eye);
    float3 const halfway = normalize(light.direction + eyeDirection);
    float const specularFactor = pow(saturate(dot(normal, halfway)), material.specularPower);
    specular = light.specularColor * material.specularColor * specularFactor;
  }

  return float4(ambient + diffuse + specular, 1);
}
