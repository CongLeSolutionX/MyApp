//
//  CAMetal3DView.m
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

// CAMetal3DView.m

#import "CAMetal3DView.h"

@implementation CAMetal3DView

- (instancetype)initWithFrame:(CGRect)frame
                       device:(id<MTLDevice>)device
                     renderer:(CubeRenderer *)renderer {
    self = [super initWithFrame:frame device:device];
    if (self) {
        self.delegate = renderer;
        self.clearColor = MTLClearColorMake(0, 0, 0, 1);
        self.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
        self.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
        self.preferredFramesPerSecond = 60;
        self.enableSetNeedsDisplay = NO;
        self.paused = NO;
    }
    return self;
}

@end
