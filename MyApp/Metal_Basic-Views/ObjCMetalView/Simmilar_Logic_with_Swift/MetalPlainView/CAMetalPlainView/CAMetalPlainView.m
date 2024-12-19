//
//  CAMetalPlainView.m
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//
#import "CAMetalPlainView.h"

@implementation CAMetalPlainView

+ (Class)layerClass {
    // This makes our view use a CAMetalLayer as its backing layer
    return [CAMetalLayer class];
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
                         queue:(id<MTLCommandQueue>)queue {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _device = device;
        _commandQueue = queue;

        CAMetalLayer *metalLayer = (CAMetalLayer *)self.layer;
        metalLayer.device = device;
        metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        metalLayer.framebufferOnly = YES;

        [self setupDisplayLink];
    }
    return self;
}

- (void)setupDisplayLink {
    // Create a CADisplayLink to synchronize rendering with the display's refresh rate
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self
                                                             selector:@selector(render)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)render {
    // Rendering code goes here
    id<CAMetalDrawable> drawable = [(CAMetalLayer *)self.layer nextDrawable];
    if (!drawable) {
        return;
    }

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"MyCommandBuffer";

    // Create a render pass descriptor
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    if (renderPassDescriptor != nil) {
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 1, 0, 1); // Green color
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;

        id<MTLRenderCommandEncoder> renderEncoder =
            [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:drawable];
    }

    [commandBuffer commit];
}

@end
