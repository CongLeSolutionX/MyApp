//
//  ObjCMetalView.m
//  MyApp
//
//  Created by Cong Le on 12/17/24.
//
// ObjCMetalView.m
// Source: https://github.com/metal-by-example/sample-code/blob/master/objc/02-ClearScreen/ClearScreen/MBEMetalView.m
//

#import "ObjCMetalView.h"
@import Metal;
@import QuartzCore.CAMetalLayer;

#if TARGET_OS_IOS
@import UIKit;
#elif TARGET_OS_OSX
@import AppKit;
#endif

// MARK: - Interface of ObjCMetalView
@interface ObjCMetalView ()
@property (nonatomic, readonly) id<MTLDevice> device;
@end

// MARK: - Implementation of ObjCMetalView
@implementation ObjCMetalView

+ (Class)layerClass {
    return [CAMetalLayer class];
}

- (void)commonInit {
    _device = MTLCreateSystemDefaultDevice();
    if (!_device) {
        NSLog(@"Metal is not supported on this device");
        return;
    }

    self.metalLayer.device = _device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;

#if TARGET_OS_IOS
    self.metalLayer.contentsScale = [UIScreen mainScreen].scale;
    self.metalLayer.framebufferOnly = YES;
#elif TARGET_OS_OSX
    self.wantsLayer = YES;
    self.layer = self.metalLayer;
    self.metalLayer.contentsScale = [NSScreen mainScreen].backingScaleFactor;
    self.metalLayer.framebufferOnly = YES;
#endif
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }

    return self;
}

- (CAMetalLayer *)metalLayer {
    return (CAMetalLayer *)self.layer;
}

#if TARGET_OS_IOS
- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self redraw];
}
#elif TARGET_OS_OSX
- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [self redraw];
}
#endif

- (void)redraw {
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    if (!drawable) {
        NSLog(@"Failed to get a drawable.");
        return;
    }
    id<MTLTexture> texture = drawable.texture;

    MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    passDescriptor.colorAttachments[0].texture = texture;
    passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 1, 1); // Blue color

    id<MTLCommandQueue> commandQueue = [self.device newCommandQueue];

    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];

    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [commandEncoder endEncoding];

    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

@end
