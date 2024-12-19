//
//  MBERenderer.h
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

// MBERenderer.h

#import <Foundation/Foundation.h>
#import "MBEMetalView.h"

@interface MBERenderer : NSObject <MBEMetalViewDelegate>

- (instancetype)initWithDevice:(id<MTLDevice>)device;

@end
