

#include <metal_stdlib>
using namespace metal;
#import "Common.h"
#import "ShaderDefs.h"

//struct VertexOut {
//  float4 position [[position]];
//};

fragment float4 fragment_main(
  constant Params &params [[buffer(12)]],
  VertexOut in [[stage_in]])
{
  // chess board
//  uint checks = 8;
//  float2 uv = in.position.xy / params.width;
//  uv = fract(uv * checks * 0.5) - 0.5;
//  float3 color = step(uv.x * uv.y, 0.0);
  
  // circle
//  float center = 0.5;
//  float radius = 0.2;
//  float2 uv = in.position.xy / params.width - center;
//  float3 color = step(length(uv), radius);
//  return float4(color, 1.0);
  
  // smoothstep + mix
//  float3 red = float3(1, 0, 0);
//  float3 blue = float3(0, 0, 1);
//  float result = smoothstep(0, params.width, in.position.x);
//  float3 color = mix(red, blue, result);
//  return float4(color, 1);

//  float3 color = normalize(in.position.xyz);
//  return float4(color, 1);

  // Hemispheric lighting (sky + ground)
  float4 sky = float4(0.34, 0.9, 1.0, 1.0);
  float4 earth = float4(0.29, 0.58, 0.2, 1.0);
  float intensity = in.normal.y * 0.5 + 0.5;
  return mix(earth, sky, intensity);

}
