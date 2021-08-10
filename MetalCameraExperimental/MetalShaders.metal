//
//  MetalShaders.metal
//  MetalShaders
//
//  Created by Xcode Developer on 8/8/21.
//

#include <metal_stdlib>
using namespace metal;

#import "MetalShaderTypes.h"

struct RasterizerData
{
    float4 clipSpacePosition [[position]];
    float2 textureCoordinate;
};

// Vertex function
vertex RasterizerData
vertexShader(
             uint                    vertexID             [[ vertex_id ]],
             constant MetalVertex  * vertexArray          [[ buffer(MetalVertexInputIndexVertices) ]],
             constant vector_uint2 * viewportSizePointer  [[ buffer(MetalVertexInputIndexViewportSize) ]]
             )
{
    
    RasterizerData out;
    float2 pixelSpacePosition = vertexArray[vertexID].position.xy;
    float2 viewportSize = float2(*viewportSizePointer);
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    out.clipSpacePosition.z = 0.0;
    out.clipSpacePosition.w = 1.0;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    
    return out;
}

// Fragment function
fragment float4
samplingShader(
               RasterizerData  in           [[ stage_in ]],
               texture2d<half> colorTexture [[ texture(MetalTextureIndexOutput) ]]
               )
{
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    
    const half4 colorSample[9] = {
        colorTexture.sample(textureSampler, in.textureCoordinate, int2( 1, -1)), // 0
        colorTexture.sample(textureSampler, in.textureCoordinate, int2( 1,  0)), // 1
        colorTexture.sample(textureSampler, in.textureCoordinate, int2( 1,  1)), // 2
        colorTexture.sample(textureSampler, in.textureCoordinate, int2( 0, -1)), // 3
        colorTexture.sample(textureSampler, in.textureCoordinate, int2( 0,  0)), // 4 (center)
        colorTexture.sample(textureSampler, in.textureCoordinate, int2( 0,  1)), // 5
        colorTexture.sample(textureSampler, in.textureCoordinate, int2(-1, -1)), // 6
        colorTexture.sample(textureSampler, in.textureCoordinate, int2(-1,  0)), // 7
        colorTexture.sample(textureSampler, in.textureCoordinate, int2(-1,  1)), // 8
    };
    
    const float weights[9] = {
        -1.0, 0.0, 1.0,
        -2.0, 0.0, 2.0,
        -1.0, 0.0, 1.0,
    };
    
    half4 sum = {0.0, 0.0, 0.0, 1.0};
    for (int i = 0; i < 9; i++)
    {
        sum += (colorSample[i] * weights[i]);
    }
    
    half4 divisor = {9.0, 9.0, 9.0, 9.0};
    half4 avg = sum / divisor;
    
    float4 output = (float4){avg.x, avg.y, avg.z, 1.0};
    return float4(output);
}

constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

// Grayscale compute kernel
kernel void
grayscaleKernel(
                texture2d<half, access::read>  inTexture  [[ texture(MetalTextureIndexInput) ]],
                texture2d<half, access::write> outTexture [[ texture(MetalTextureIndexOutput) ]],
                uint2                          gid        [[ thread_position_in_grid ]]
                )
{
    if((gid.x >= outTexture.get_width()) || (gid.y >= outTexture.get_height()))
    {
        return;
    }
    
    half4 inColor  = inTexture.read(gid);
    half  gray     = dot(inColor.rgb, kRec709Luma);
    outTexture.write(half4(gray, gray, gray, 1.0), gid);
}

