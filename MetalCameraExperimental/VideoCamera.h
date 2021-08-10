//
//  VideoCamera.h
//  VideoCamera
//
//  Created by Xcode Developer on 8/8/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCamera : NSObject

+ (VideoCamera *)setAVCaptureVideoDataOutputSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)videoOutputDelegate;

@property (nonatomic) CGSize videoDimensions;

@end

NS_ASSUME_NONNULL_END
