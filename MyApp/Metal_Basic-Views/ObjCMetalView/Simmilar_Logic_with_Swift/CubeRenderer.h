//
//  CubeRenderer.h
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

// CubeRenderer.h

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

@interface CubeRenderer : NSObject <MTKViewDelegate>

- (instancetype)initWithDevice:(id<MTLDevice>)device;

@end
