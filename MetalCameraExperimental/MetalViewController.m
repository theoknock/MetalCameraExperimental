//
//  ViewController.m
//  MetalCameraExperimental
//
//  Created by Xcode Developer on 8/8/21.
//

#import "MetalViewController.h"
#import "MetalRenderer.h"

@interface MetalViewController ()

@end

@implementation MetalViewController
{
    MetalRenderer * renderer;
}

@dynamic view;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setDevice:self.view.preferredDevice];
    [self.view setFramebufferOnly:FALSE];
    
    renderer = [[MetalRenderer alloc] initWithMetalKitView:self.view];
}


@end
