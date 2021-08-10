//
//  MetalShaderTypes.h
//  MetalShaderTypes
//
//  Created by Xcode Developer on 8/8/21.
//

#ifndef MetalShaderTypes_h
#define MetalShaderTypes_h

#include <simd/simd.h>

typedef enum MetalVertexInputIndex
{
    MetalVertexInputIndexVertices     = 0,
    MetalVertexInputIndexViewportSize = 1,
} MetalVertexInputIndex;

typedef enum MetalTextureIndex
{
    MetalTextureIndexInput  = 0,
    MetalTextureIndexOutput = 1,
} MetalTextureIndex;

typedef struct
{
    vector_float2 position;
    vector_float2 textureCoordinate;
} MetalVertex;

#endif /* MetalShaderTypes_h */
