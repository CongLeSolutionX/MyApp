//
//  ObjCMetal2DView.h
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

#import <TargetConditionals.h>


#if TARGET_OS_IOS
@import UIKit;
typedef UIView MyObjCView;
#elif TARGET_OS_OSX
@import AppKit;
typedef NSView MyObjCView;
#endif

@interface ObjCMetal2DView : MyObjCView

@property (readonly) CAMetalLayer *metalLayer;

@end
