//
//  ObjCMetalView.h
//  MyApp
//
//  Created by Cong Le on 12/17/24.
//
//
//  ObjCMetalView.h

#import <TargetConditionals.h>



@import QuartzCore.CAMetalLayer; // Import CAMetalLayer from framework QuartzCore
// Alternatively, you can use:
// #import <QuartzCore/CAMetalLayer.h>


#if TARGET_OS_IOS
@import UIKit;
typedef UIView MyObjCView;
#elif TARGET_OS_OSX
@import AppKit;
typedef NSView MyObjCView;
#endif


@interface ObjCMetalView : MyObjCView

@property (readonly) CAMetalLayer *metalLayer;

@end
