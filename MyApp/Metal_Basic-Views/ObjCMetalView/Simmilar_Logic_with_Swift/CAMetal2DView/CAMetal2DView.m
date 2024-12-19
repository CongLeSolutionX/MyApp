//
//  CAMetal2DView.m
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

#import "CAMetal2DView.h"
#import <QuartzCore/CAMetalLayer.h>
#import <simd/simd.h>

typedef struct {
    vector_float2 position;
    vector_float4 color;
} Vertex;

@interface CAMetal2DView ()

@property (nonatomic, strong) CAMetalLayer *metalLayer;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, assign) NSUInteger numVertices;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation CAMetal2DView

+ (Class)layerClass {
    return [CAMetalLayer class];
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
                         queue:(id<MTLCommandQueue>)queue {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _device = device;
        _queue = queue;
        
        [self setupMetal];
        [self setupPipeline];
        [self setupVertices];
        [self setupDisplayLink];
    }
    return self;
}

- (void)setupMetal {
    self.metalLayer = (CAMetalLayer *)self.layer;
    self.metalLayer.device = self.device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    self.metalLayer.framebufferOnly = YES;
}

- (void)setupPipeline {
    // Load the shaders from the default library
    id<MTLLibrary> defaultLibrary = [self.device newDefaultLibrary];
    if (!defaultLibrary) {
        NSLog(@"Failed to find the default library.");
        return;
    }
    
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertex_shader_for_2D_view"];
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragment_shader_for_2d_view"];
    
    if (!vertexFunction || !fragmentFunction) {
        NSLog(@"Failed to find shaders in the library.");
        return;
    }
    
    // Create a pipeline state descriptor
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"Simple Pipeline";
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.metalLayer.pixelFormat;
    
    NSError *error = nil;
    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!self.pipelineState) {
        NSLog(@"Failed to create pipeline state: %@", error);
    }
}

- (void)setupVertices {
    static const Vertex triangleVertices[] = {
        { {  0.0,  0.5 }, { 1, 0, 0, 1 } }, // top center, red
        { { -0.5, -0.5 }, { 0, 1, 0, 1 } }, // bottom left, green
        { {  0.5, -0.5 }, { 0, 0, 1, 1 } }, // bottom right, blue
    };
    
    self.vertexBuffer = [self.device newBufferWithBytes:triangleVertices
                                                 length:sizeof(triangleVertices)
                                                options:MTLResourceStorageModeShared];
    self.numVertices = sizeof(triangleVertices) / sizeof(Vertex);
}

- (void)setupDisplayLink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)render {
    // Create a new command buffer
    id<MTLCommandBuffer> commandBuffer = [self.queue commandBuffer];
    commandBuffer.label = @"Command Buffer";
    
    // Get a drawable
    id<CAMetalDrawable> drawable = [self.metalLayer nextDrawable];
    if (!drawable) {
        NSLog(@"Failed to get a drawable.");
        return;
    }
    
    // Create a render pass descriptor
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    // Create a render command encoder
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder setRenderPipelineState:self.pipelineState];
    [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    
    // Draw the triangle
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.numVertices];
    
    [renderEncoder endEncoding];
    
    // Present the drawable
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (void)dealloc {
    [self.displayLink invalidate];
}

@end
