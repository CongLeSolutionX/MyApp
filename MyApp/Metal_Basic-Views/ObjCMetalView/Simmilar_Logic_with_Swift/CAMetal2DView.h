//
//  CAMetal2DView.h
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

@interface CAMetal2DView : UIView

- (instancetype)initWithDevice:(id<MTLDevice>)device
                         queue:(id<MTLCommandQueue>)queue;

@property (nonatomic, readonly) id<MTLDevice> device;
@property (nonatomic, readonly) id<MTLCommandQueue> queue;

@end
