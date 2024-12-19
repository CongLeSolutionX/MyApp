//
//  MBERenderer.m
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//
// Source: https://github.com/metal-by-example/sample-code/blob/master/objc/04-DrawingIn3D/DrawingIn3D/MBERenderer.m
//


#import "RendererFor3DView.h"
#import "MBEMathUtilities.h"

#import <Metal/Metal.h>
#import <simd/simd.h>

static const NSInteger MBEInFlightBufferCount = 3;

typedef uint16_t MBEIndex;
const MTLIndexType MBEIndexType = MTLIndexTypeUInt16;

typedef struct {
    vector_float4 position;
    vector_float4 color;
} MBEVertex;

typedef struct {
    matrix_float4x4 modelViewProjectionMatrix;
} MBEUniforms;

static inline uint64_t AlignUp(uint64_t n, uint32_t alignment) {
    return ((n + alignment - 1) / alignment) * alignment;
}

static const uint32_t MBEBufferAlignment = 256;

@interface RendererFor3DView ()

@property (strong) id<MTLDevice> device;
@property (strong) id<MTLBuffer> vertexBuffer;
@property (strong) id<MTLBuffer> indexBuffer;
@property (strong) id<MTLBuffer> uniformBuffer;
@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLRenderPipelineState> renderPipelineState;
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (strong) dispatch_semaphore_t displaySemaphore;
@property (assign) NSInteger bufferIndex;
@property (assign) float rotationX, rotationY, time;

@end

@implementation RendererFor3DView

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    if ((self = [super init])) {
        _device = device;
        _displaySemaphore = dispatch_semaphore_create(MBEInFlightBufferCount);
        [self makePipeline];
        [self makeBuffers];
    }
    return self;
}

- (void)makePipeline {
    self.commandQueue = [self.device newCommandQueue];

    id<MTLLibrary> library = [self.device newDefaultLibrary];

    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertex_project"];
    pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragment_flatcolor"];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;

    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    self.depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];

    NSError *error = nil;
    self.renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                           error:&error];

    if (!self.renderPipelineState)
    {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
}

- (void)makeBuffers {
    static const MBEVertex vertices[] = {
        { .position = { -1,  1,  1, 1 }, .color = { 0, 1, 1, 1 } },
        { .position = { -1, -1,  1, 1 }, .color = { 0, 0, 1, 1 } },
        { .position = {  1, -1,  1, 1 }, .color = { 1, 0, 1, 1 } },
        { .position = {  1,  1,  1, 1 }, .color = { 1, 1, 1, 1 } },
        { .position = { -1,  1, -1, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = { -1, -1, -1, 1 }, .color = { 0, 0, 0, 1 } },
        { .position = {  1, -1, -1, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = {  1,  1, -1, 1 }, .color = { 1, 1, 0, 1 } }
    };

    static const MBEIndex indices[] = {
        3, 2, 6, 6, 7, 3,
        4, 5, 1, 1, 0, 4,
        4, 0, 3, 3, 7, 4,
        1, 5, 6, 6, 2, 1,
        0, 1, 2, 2, 3, 0,
        7, 6, 5, 5, 4, 7
    };

    _vertexBuffer = [self.device newBufferWithBytes:vertices
                                             length:sizeof(vertices)
                                            options:MTLResourceStorageModeShared];
    [_vertexBuffer setLabel:@"Vertices"];

    _indexBuffer = [self.device newBufferWithBytes:indices
                                            length:sizeof(indices)
                                           options:MTLResourceStorageModeShared];
    [_indexBuffer setLabel:@"Indices"];

    _uniformBuffer = [self.device newBufferWithLength:AlignUp(sizeof(MBEUniforms), MBEBufferAlignment) * MBEInFlightBufferCount
                                              options:MTLResourceStorageModeShared];
    [_uniformBuffer setLabel:@"Uniforms"];
}

- (void)updateUniformsForView:(CAMetal3DView *)view duration:(NSTimeInterval)duration {
    self.time += duration;
    self.rotationX += duration * (M_PI / 2);
    self.rotationY += duration * (M_PI / 3);
    float scaleFactor = sinf(5 * self.time) * 0.25 + 1;
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
    const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);

    const vector_float3 cameraTranslation = { 0, 0, -5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);

    const CGSize drawableSize = view.metalLayer.drawableSize;
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1;
    const float far = 100;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect, fov, near, far);

    MBEUniforms uniforms;
    uniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix));

    const NSUInteger uniformBufferOffset = AlignUp(sizeof(MBEUniforms), MBEBufferAlignment) * self.bufferIndex;
    memcpy([self.uniformBuffer contents] + uniformBufferOffset, &uniforms, sizeof(uniforms));
}

- (void)drawInView:(CAMetal3DView *)view {
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);

    view.clearColor = MTLClearColorMake(0.95, 0.95, 0.95, 1);

    [self updateUniformsForView:view duration:view.frameDuration];

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    MTLRenderPassDescriptor *passDescriptor = [view currentRenderPassDescriptor];

    if (!passDescriptor)
    {
        dispatch_semaphore_signal(self.displaySemaphore);
        return;
    }

    id<MTLRenderCommandEncoder> renderPass = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [renderPass setRenderPipelineState:self.renderPipelineState];
    [renderPass setDepthStencilState:self.depthStencilState];
    [renderPass setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderPass setCullMode:MTLCullModeBack];

    const NSUInteger uniformBufferOffset = AlignUp(sizeof(MBEUniforms), MBEBufferAlignment) * self.bufferIndex;

    [renderPass setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [renderPass setVertexBuffer:self.uniformBuffer offset:uniformBufferOffset atIndex:1];

    [renderPass drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                           indexCount:self.indexBuffer.length / sizeof(MBEIndex)
                            indexType:MBEIndexType
                          indexBuffer:self.indexBuffer
                    indexBufferOffset:0];

    [renderPass endEncoding];

    [commandBuffer presentDrawable:view.currentDrawable];

    __block dispatch_semaphore_t semaphore = self.displaySemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        self.bufferIndex = (self.bufferIndex + 1) % MBEInFlightBufferCount;
        dispatch_semaphore_signal(semaphore);
    }];

    [commandBuffer commit];
}

@end
