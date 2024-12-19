//
//  ObjCMetal2DView.m
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

#import "ObjCMetal2DView.h"
@import Metal;
@import simd;

#if TARGET_OS_IOS
@import UIKit;
#elif TARGET_OS_OSX
@import AppKit;
#endif

typedef struct {
    vector_float4 position;
    vector_float4 color;
} ShaderVertexFor2DView;

@interface ObjCMetal2DView ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipeline;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@end

@implementation ObjCMetal2DView

@synthesize device=device;

+ (Class)layerClass {
    return [CAMetalLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self makeDevice];
        [self makeBuffers];
        [self makePipeline];
    }
    
    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    else {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // During the first layout pass, we will not be in a view hierarchy, so we guess our scale
    CGFloat scale = [UIScreen mainScreen].scale;
    
    // If we've moved to a window by the time our frame is being set, we can take its scale as our own
    if (self.window) {
        scale = self.window.screen.scale;
    }
    
    CGSize drawableSize = self.bounds.size;
    
    // Since drawable size is in pixels, we need to multiply by the scale to move from points to pixels
    drawableSize.width *= scale;
    drawableSize.height *= scale;
    
    self.metalLayer.drawableSize = drawableSize;
}

- (CAMetalLayer *)metalLayer {
    return (CAMetalLayer *)self.layer;
}

- (void)makeDevice {
    device = MTLCreateSystemDefaultDevice();
    self.metalLayer.device = device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}

- (void)makePipeline {
    id<MTLLibrary> library = [device newDefaultLibrary];
    
    id<MTLFunction> vertexFunc = [library newFunctionWithName:@"main_vertex_for_2D_view"];
    id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"main_fragment_for_2D_view"];

    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.vertexFunction = vertexFunc;
    pipelineDescriptor.fragmentFunction = fragmentFunc;
    
    NSError *error = nil;
    _pipeline = [device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                       error:&error];

    if (!_pipeline) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
    
    _commandQueue = [device newCommandQueue];
}

- (void)makeBuffers {
    static const ShaderVertexFor2DView vertices[] = {
        { .position = {  0.0,  0.5, 0, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = { -0.5, -0.5, 0, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = {  0.5, -0.5, 0, 1 }, .color = { 0, 0, 1, 1 } }
    };

    _vertexBuffer = [device newBufferWithBytes:vertices
                                        length:sizeof(vertices)
                                       options:MTLResourceCPUCacheModeDefaultCache];
}

- (void)redraw {
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    id<MTLTexture> framebufferTexture = drawable.texture;

    if (drawable) {
        MTLRenderPassDescriptor *passDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
        passDescriptor.colorAttachments[0].texture = framebufferTexture;
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.85, 0.85, 0.85, 1);
        passDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        passDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;

        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

        id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
        [commandEncoder setRenderPipelineState:self.pipeline];
        [commandEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        [commandEncoder endEncoding];
        
        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit];
    }
}

- (void)displayLinkDidFire:(CADisplayLink *)displayLink {
    [self redraw];
}

@end
