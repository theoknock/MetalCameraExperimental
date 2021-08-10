//
//  MetalRenderer.h
//  MetalRenderer
//
//  Created by Xcode Developer on 8/8/21.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalRenderer : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;

@end

NS_ASSUME_NONNULL_END
