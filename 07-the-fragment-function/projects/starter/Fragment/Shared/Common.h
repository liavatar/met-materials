

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
  matrix_float4x4 modelMatrix;
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
} Uniforms;

typedef struct {
  uint width;
  uint height;
} Params;

typedef enum {
  VertexBuffer = 0,
  UniformsBuffer = 11,
  ParamsBuffer = 12
} BufferIndices;


#endif /* Common_h */
