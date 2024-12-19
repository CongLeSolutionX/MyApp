//
//  CAMetalPlainView.h
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAMetalPlainView : UIView

- (instancetype)initWithDevice:(id<MTLDevice>)device
                         queue:(id<MTLCommandQueue>)queue;

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

@end

NS_ASSUME_NONNULL_END
