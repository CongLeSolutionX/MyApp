//
//  MBERenderer.h
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

#import <Foundation/Foundation.h>
#import "CAMetal3DView.h"

@interface RendererFor3DView : NSObject <MBEMetalViewDelegate>

- (instancetype)initWithDevice:(id<MTLDevice>)device;

@end
