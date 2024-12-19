//
//  CAMetal3DView.h
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

// CAMetal3DView.h

#import <MetalKit/MetalKit.h>
#import "CubeRenderer.h"

@interface CAMetal3DView : MTKView

- (instancetype)initWithFrame:(CGRect)frame
                       device:(id<MTLDevice>)device
                     renderer:(CubeRenderer *)renderer;

@end
