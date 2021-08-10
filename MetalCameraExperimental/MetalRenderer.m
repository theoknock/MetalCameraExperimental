//
//  MetalRenderer.m
//  MetalRenderer
//
//  Created by Xcode Developer on 8/8/21.
//

#import "MetalRenderer.h"
#import "VideoCamera.h"
#import "MetalShaderTypes.h"

#include "GlobalDispatch.h"

@implementation MetalRenderer
{
    
//    id<MTLDevice>(^abc)(MTKView *);
    //_device = ^ (MTKView * view) {
//    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
//    return view.device;
//} (mtkView);
     
    id<MTLTexture>(^create_texture)(CVPixelBufferRef);
    void(^(^draw_texture)(id<MTLTexture>))(void);
//    __block void(^draw_texture)(id<MTLTexture>);
}

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view {
    if (self = [super init])
    {
        CGSize video_dimensions = [[VideoCamera setAVCaptureVideoDataOutputSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)self] videoDimensions];
        create_texture = ^ (CVMetalTextureCacheRef texture_cache_ref) {
            MTLPixelFormat pixelFormat = view.colorPixelFormat;
            CFStringRef textureCacheKeys[2] = {kCVMetalTextureCacheMaximumTextureAgeKey, kCVMetalTextureUsage};
            float maximumTextureAge = (1.0); // / view.preferredFramesPerSecond);
            CFNumberRef maximumTextureAgeValue = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &maximumTextureAge);
            MTLTextureUsage textureUsage = MTLTextureUsageShaderRead;
            CFNumberRef textureUsageValue = CFNumberCreate(NULL, kCFNumberNSIntegerType, &textureUsage);
            CFTypeRef textureCacheValues[2] = {maximumTextureAgeValue, textureUsageValue};
            CFIndex textureCacheAttributesCount = 2;
            CFDictionaryRef cacheAttributes = CFDictionaryCreate(NULL, (const void **)textureCacheKeys, (const void **)textureCacheValues, textureCacheAttributesCount, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            
            return ^ id<MTLTexture> _Nonnull (CVPixelBufferRef pixel_buffer) {
                @autoreleasepool {
                    __autoreleasing id<MTLTexture> texture = nil;
                    CVPixelBufferLockBaseAddress(pixel_buffer, kCVPixelBufferLock_ReadOnly);
                    {
                        CVMetalTextureRef metalTextureRef = NULL;
                        CVMetalTextureCacheCreateTextureFromImage(NULL, texture_cache_ref, pixel_buffer, cacheAttributes, pixelFormat, CVPixelBufferGetWidth(pixel_buffer), CVPixelBufferGetHeight(pixel_buffer), 0, &metalTextureRef);
                        texture = CVMetalTextureGetTexture(metalTextureRef);
                        CFRelease(metalTextureRef);
                    }
                    CVPixelBufferUnlockBaseAddress(pixel_buffer, kCVPixelBufferLock_ReadOnly);
                    return texture;
                }
            };
        }(^ () {
            CFStringRef textureCacheKeys[2] = {kCVMetalTextureCacheMaximumTextureAgeKey, kCVMetalTextureUsage};
            float maximumTextureAge = (1.0); // / view.preferredFramesPerSecond);
            CFNumberRef maximumTextureAgeValue = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &maximumTextureAge);
            MTLTextureUsage textureUsage = MTLTextureUsageShaderRead;
            CFNumberRef textureUsageValue = CFNumberCreate(NULL, kCFNumberNSIntegerType, &textureUsage);
            CFTypeRef textureCacheValues[2] = {maximumTextureAgeValue, textureUsageValue};
            CFIndex textureCacheAttributesCount = 2;
            CFDictionaryRef cacheAttributes = CFDictionaryCreate(NULL, (const void **)textureCacheKeys, (const void **)textureCacheValues, textureCacheAttributesCount, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            
            CVMetalTextureCacheRef textureCache;
            CVMetalTextureCacheCreate(NULL, cacheAttributes, view.preferredDevice, NULL, &textureCache);
            CFShow(cacheAttributes);
            CFRelease(textureUsageValue);
            CFRelease(cacheAttributes);
            
            return textureCache;
        }());
        
        draw_texture = ^ () {
            id<MTLLibrary> defaultLibrary = [view.preferredDevice newDefaultLibrary];
            id<MTLFunction> kernelFunction = [defaultLibrary newFunctionWithName:@"grayscaleKernel"];
            __autoreleasing NSError * error = nil;
            id<MTLComputePipelineState> computePipelineState = [view.preferredDevice newComputePipelineStateWithFunction:kernelFunction error:&error];
            NSAssert(computePipelineState, @"Failed to create compute pipeline state: %@", error);
            
            NSUInteger w = computePipelineState.threadExecutionWidth;
            NSUInteger h = computePipelineState.maxTotalThreadsPerThreadgroup / w;
            MTLSize threadsPerThreadgroup = MTLSizeMake(w, h, 1);
            MTLSize threadgroupsPerGrid   = MTLSizeMake((video_dimensions.height  + w - 1) / w,
                                                        (video_dimensions.width + h - 1) / h,
                                                        1);
            NSLog(@"threadsPerThreadgroup: %lu x %lu\tthreadgroupsPerGrid: %lu x %lu",
                  threadsPerThreadgroup.width,
                  threadsPerThreadgroup.height,
                  threadgroupsPerGrid.width,
                  threadgroupsPerGrid.height);
            
            [(CAMetalLayer *)(view.layer) setDrawableSize:(CGSize){.width = video_dimensions.height,
                                                                   .height = video_dimensions.width}];
            
//                        MTLTextureDescriptor * descriptor = [MTLTextureDescriptor
//                                                             texture2DDescriptorWithPixelFormat:view.colorPixelFormat
//                                                             width:3840.0//video_dimensions.width
//                                                             height:2160.0 //video_dimensions.height
//                                                             mipmapped:FALSE];
//                        [descriptor setUsage:MTLTextureUsageShaderWrite | MTLTextureUsageShaderRead];
//                        id<MTLTexture> computeTexture = [view.preferredDevice newTextureWithDescriptor:descriptor];
//
//            static const MetalVertex quadVertices[] =
//            {
//                { {  3840,   2160 },  { 0.f, 0.f } },
//                { { -3840,  -2160 },  { 1.f, 1.f } },
//                { { -3840,   2160 },  { 0.f, 1.f } },
//
//                { {  3840,   2160 },  { 0.f, 0.f } },
//                { {  3840,  -2160 },  { 1.f, 0.f } },
//                { { -3840,  -2160 },  { 1.f, 1.f } },
//            };
//
//            vector_uint2 viewportSize = {[[UIScreen mainScreen] nativeBounds].size.height, [[UIScreen mainScreen] nativeBounds].size.width};
//
//            id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
//            id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];
//            MTLRenderPipelineDescriptor * renderPipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
//            renderPipelineStateDescriptor.label = @"Simple Render Pipeline";
//            renderPipelineStateDescriptor.vertexFunction = vertexFunction;
//            renderPipelineStateDescriptor.fragmentFunction = fragmentFunction;
//            renderPipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
//            id<MTLRenderPipelineState> renderPipelineState = [view.preferredDevice newRenderPipelineStateWithDescriptor:renderPipelineStateDescriptor error:&error];
//            NSAssert(renderPipelineState, @"Failed to create render pipeline state: %@", error);
//
            
            id<MTLCommandQueue> commandQueue = [view.preferredDevice newCommandQueue];
//
            MTLCaptureManager * captureManager = [MTLCaptureManager sharedCaptureManager];
            id<MTLCaptureScope> captureScope = [captureManager newCaptureScopeWithDevice:view.preferredDevice];
            MTLCaptureDescriptor * captureDescriptor = [[MTLCaptureDescriptor alloc] init];
            [captureDescriptor setCaptureObject:captureScope];
            @try {
                __autoreleasing NSError * error;
                [captureManager startCaptureWithDescriptor:captureDescriptor error:&error];
                if (error) NSLog(@"%@", error.debugDescription);
            } @catch (NSException *exception) {
                NSLog(@"Capture manager exception on start: %@", exception.debugDescription);
            } @finally {
                NSLog(@"[[(MTLCaptureManager *)sharedCaptureManager] setCaptureObject:MTLCreateSystemDefaultDevice()]");
            }

            return ^ (id<MTLTexture> source_texture) {
                return ^ (void) {
                @autoreleasepool {
                    __autoreleasing id<CAMetalDrawable> layerDrawable = [(CAMetalLayer *)(view.layer) nextDrawable];
                    __autoreleasing id<MTLTexture> drawableTexture = [layerDrawable texture];
                    
//                                    [captureScope beginScope];
                    
                    __autoreleasing id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
                    commandBuffer.label = @"MyCommand";
                    
                    __autoreleasing id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
                    [computeEncoder setComputePipelineState:computePipelineState];
                    [computeEncoder setTexture:source_texture
                                       atIndex:MetalTextureIndexInput];
                    [computeEncoder setTexture:drawableTexture
                                       atIndex:MetalTextureIndexOutput];
                    [computeEncoder dispatchThreadgroups:threadgroupsPerGrid
                                   threadsPerThreadgroup:threadsPerThreadgroup];
                    [computeEncoder endEncoding];
                    
//                    __autoreleasing MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
//                    renderPassDescriptor.colorAttachments[0].texture = drawableTexture;
//                    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
//                    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0,0.0,0.0,1.0);
//                    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
//
//                    if(renderPassDescriptor != nil)
//                    {
//                        __autoreleasing id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
//                        renderEncoder.label = @"MyRenderEncoder";
//                        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, viewportSize.y, viewportSize.x, -1.0, 1.0}];
//                        [renderEncoder setRenderPipelineState:renderPipelineState];
//
//                        // Encode the vertex data.
//                        [renderEncoder setVertexBytes:quadVertices
//                                               length:sizeof(quadVertices)
//                                              atIndex:MetalVertexInputIndexVertices];
//
//                        // Encode the viewport data.
//                        [renderEncoder setVertexBytes:&viewportSize
//                                               length:sizeof(viewportSize)
//                                              atIndex:MetalVertexInputIndexViewportSize];
//
//                        // Encode the output texture
//                        [renderEncoder setFragmentTexture:computeTexture
//                                                  atIndex:MetalTextureIndexOutput];
//
//                        // Draw the quad.
//                        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
//                                          vertexStart:0
//                                          vertexCount:6];
//
//                        [renderEncoder endEncoding];
//
                        [commandBuffer presentDrawable:layerDrawable];
//                    }
                    
                    [commandBuffer commit];
//                                    [captureScope endScope];
                }
            };
            };
        }();
    }
    
    return self;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    dispatch_async(pixel_buffer_data_queue, draw_texture(create_texture(CMSampleBufferGetImageBuffer(sampleBuffer))));
}

@end
