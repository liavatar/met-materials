

#include <metal_stdlib>
using namespace metal;

// MARK: - vertex shader for simple quad rendering (including a timer float variable)
// changing from float3 to packed_float3 to avoid SIMD_float3 padding from 3 bytes to 4 bytes
//vertex float4 vertex_main(
//  constant packed_float3 *vertices [[buffer(0)]],
//  constant ushort *indices [[buffer(1)]], // using vertex index
//  constant float &timer [[buffer(11)]],
//  uint vertexID [[vertex_id]])
//{
//  //float4 position = float4(vertices[vertexID], 1);
//  float4 position = float4(vertices[indices[vertexID]], 1); // using vertex index
//  position.y += timer;
//  return position;
//}

// MARK: - 3 using vertex descriptor
// describe each per-vertex input with the [[stage_in]] attribute. The GPU now looks at the pipeline state’s vertex descriptor.
// [[attribute(0)]] is the attribute in the vertex descriptor that describes the position.

//vertex float4 vertex_main(
//  float4 position [[attribute(0)]] [[stage_in]],
//  constant float &timer [[buffer(11)]])
//{
//  return position;
//}

// MARK: - 4 adding color to vertex
// You can only use [[stage_in]] on one parameter, so create a new VertexIn structure:

struct VertexIn {
  float4 position [[attribute(0)]];
  float4 color [[attribute(1)]];
};

// MARK: - 5 adding color output
struct VertexOut {
  float4 position [[position]];
  float4 color;
  float pointSize [[point_size]]; //The [[point_size]] attribute will tell the GPU what point size to use.
};

vertex VertexOut vertex_main(
  VertexIn vIn [[stage_in]],
  constant float &timer [[buffer(11)]])
{
  vIn.position.y += timer;
  // return vIn.position;
  
  // MARK: - 5 adding color output
  VertexOut vOut {
    .position = vIn.position,
    .color = vIn.color,
    .pointSize = 30
  };
  return vOut;
}

fragment float4 fragment_main(VertexOut fIn [[stage_in]]) {
  return fIn.color;
}

//fragment float4 fragment_main() {
//  return float4(0, 0, 1, 1);
//}
