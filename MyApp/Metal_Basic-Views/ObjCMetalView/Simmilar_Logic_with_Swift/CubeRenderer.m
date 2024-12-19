//
//  CubeRenderer.m
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//
// CubeRenderer.m

#import "CubeRenderer.h"
#import <simd/simd.h>

@interface CubeRenderer ()

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLDepthStencilState> depthStencilState;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, assign) NSUInteger vertexCount;

@property (nonatomic, assign) simd_float4x4 modelMatrix;
@property (nonatomic, assign) simd_float4x4 viewMatrix;
@property (nonatomic, assign) simd_float4x4 projectionMatrix;

@property (nonatomic, assign) float rotationAngle;

@end

@implementation CubeRenderer

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    if (self) {
        _device = device;
        [self setupMetal];
        [self setupMatrices];
    }
    return self;
}

- (void)setupMetal {
    // Create command queue
    self.commandQueue = [self.device newCommandQueue];

    // Load shaders from the default library
    id<MTLLibrary> library = [self.device newDefaultLibrary];

    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragmentShader"];

    // Create pipeline state
    MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.label = @"Cube Pipeline";
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;

    NSError *error = nil;
    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];

    if (!self.pipelineState) {
        NSLog(@"Failed to create pipeline state: %@", error.localizedDescription);
    }

    // Create depth stencil state
    MTLDepthStencilDescriptor *depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    self.depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];

    // Create vertex data
    [self setupVertexBuffer];
}

- (void)setupVertexBuffer {
    // Define cube vertices
    static const float cubeVertices[] = {
        // Positions               // Colors
        // Front face
        -0.5f, -0.5f,  0.5f,       1, 0, 0, 1,
         0.5f, -0.5f,  0.5f,       0, 1, 0, 1,
         0.5f,  0.5f,  0.5f,       0, 0, 1, 1,
        -0.5f,  0.5f,  0.5f,       1, 1, 0, 1,
        // Back face
        -0.5f, -0.5f, -0.5f,       1, 0, 1, 1,
         0.5f, -0.5f, -0.5f,       0, 1, 1, 1,
         0.5f,  0.5f, -0.5f,       1, 1, 1, 1,
        -0.5f,  0.5f, -0.5f,       0, 0, 0, 1,
    };

    // Define cube indices
    static const uint16_t cubeIndices[] = {
        // Front
        0, 1, 2, 2, 3, 0,
        // Right
        1, 5, 6, 6, 2, 1,
        // Back
        5, 4, 7, 7, 6, 5,
        // Left
        4, 0, 3, 3, 7, 4,
        // Top
        3, 2, 6, 6, 7, 3,
        // Bottom
        4, 5, 1, 1, 0, 4,
    };

    self.vertexCount = sizeof(cubeIndices) / sizeof(uint16_t);

    self.vertexBuffer = [self.device newBufferWithBytes:cubeVertices
                                                 length:sizeof(cubeVertices)
                                                options:MTLResourceStorageModeShared];

    self.indexBuffer = [self.device newBufferWithBytes:cubeIndices
                                                length:sizeof(cubeIndices)
                                               options:MTLResourceStorageModeShared];
}

- (void)setupMatrices {
    // Initialize model, view, and projection matrices
    self.modelMatrix = matrix_identity_float4x4;
    self.viewMatrix = [self matrix_look_at_left_hand:(simd_float3){0, 0, -2}
                                              center:(simd_float3){0, 0, 0}
                                                  up:(simd_float3){0, 1, 0}];
    CGSize drawableSize = CGSizeMake(375, 667); // Replace with your view's size
    float aspect = drawableSize.width / drawableSize.height;
    self.projectionMatrix = [self matrix_perspective_left_hand:(65.0f * M_PI / 180.0f)
                                                        aspect:aspect
                                                         nearZ:0.1f
                                                          farZ:100.0f];
}

#pragma mark - MTKViewDelegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    float aspect = size.width / size.height;
    self.projectionMatrix = [self matrix_perspective_left_hand:(65.0f * M_PI / 180.0f)
                                                        aspect:aspect
                                                         nearZ:0.1f
                                                          farZ:100.0f];
}

- (void)drawInMTKView:(MTKView *)view {
    // Update rotation
    self.rotationAngle += 0.01f;
    self.modelMatrix = [self matrix_rotate:self.rotationAngle axis:(simd_float3){0, 1, 0}];

    // Create command buffer
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    // Create render pass descriptor
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (!renderPassDescriptor) {
        // Skip rendering if there's no render pass
        return;
    }

    // Create render encoder
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder setRenderPipelineState:self.pipelineState];
    [renderEncoder setDepthStencilState:self.depthStencilState];

    // Set vertex buffer
    [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];

    // Create a struct to hold the uniforms
    typedef struct {
        simd_float4x4 modelMatrix;
        simd_float4x4 viewMatrix;
        simd_float4x4 projectionMatrix;
    } Uniforms;

    Uniforms uniforms;
    uniforms.modelMatrix = self.modelMatrix;
    uniforms.viewMatrix = self.viewMatrix;
    uniforms.projectionMatrix = self.projectionMatrix;

    // Set uniforms
    [renderEncoder setVertexBytes:&uniforms length:sizeof(uniforms) atIndex:1];

    // Draw cube using indices
    [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                              indexCount:self.vertexCount
                               indexType:MTLIndexTypeUInt16
                             indexBuffer:self.indexBuffer
                       indexBufferOffset:0];

    // End encoding
    [renderEncoder endEncoding];

    // Present drawable
    [commandBuffer presentDrawable:view.currentDrawable];

    // Commit command buffer
    [commandBuffer commit];
}

#pragma mark - Math Helper Functions

- (simd_float4x4)matrix_perspective_left_hand:(float)fovyRadians aspect:(float)aspect nearZ:(float)nearZ farZ:(float)farZ {
    float yScale = 1 / tanf(fovyRadians * 0.5f);
    float xScale = yScale / aspect;
    float zRange = farZ - nearZ;
    float zScale = farZ / zRange;
    float wzScale = -nearZ * farZ / zRange;

    simd_float4x4 m = (simd_float4x4){
        .columns = {
            { xScale, 0,      0,       0 },
            { 0,      yScale, 0,       0 },
            { 0,      0,      zScale,  1 },
            { 0,      0,      wzScale, 0 }
        }
    };
    return m;
}

- (simd_float4x4)matrix_rotate:(float)angle axis:(simd_float3)axis {
    axis = simd_normalize(axis);
    float c = cosf(angle);
    float s = sinf(angle);
    float ci = 1 - c;

    simd_float4x4 m;
    m.columns[0] = (simd_float4){
        c + axis.x * axis.x * ci,
        axis.y * axis.x * ci + axis.z * s,
        axis.z * axis.x * ci - axis.y * s,
        0 };
    m.columns[1] = (simd_float4){
        axis.x * axis.y * ci - axis.z * s,
        c + axis.y * axis.y * ci,
        axis.z * axis.y * ci + axis.x * s,
        0 };
    m.columns[2] = (simd_float4){
        axis.x * axis.z * ci + axis.y * s,
        axis.y * axis.z * ci - axis.x * s,
        c + axis.z * axis.z * ci,
        0 };
    m.columns[3] = (simd_float4){ 0, 0, 0, 1 };
    return m;
}

- (simd_float4x4)matrix_look_at_left_hand:(simd_float3)eye center:(simd_float3)center up:(simd_float3)up {
    simd_float3 zAxis = simd_normalize(center - eye);
    simd_float3 xAxis = simd_normalize(simd_cross(up, zAxis));
    simd_float3 yAxis = simd_cross(zAxis, xAxis);

    simd_float4x4 viewMatrix = {
        .columns = {
            (simd_float4){ xAxis.x, yAxis.x, zAxis.x, 0 },
            (simd_float4){ xAxis.y, yAxis.y, zAxis.y, 0 },
            (simd_float4){ xAxis.z, yAxis.z, zAxis.z, 0 },
            (simd_float4){ -simd_dot(xAxis, eye), -simd_dot(yAxis, eye), -simd_dot(zAxis, eye), 1 }
        }
    };
    return viewMatrix;
}

@end
