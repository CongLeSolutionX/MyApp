//
//  ObjCViewController.h
//  MyApp
//
//  Created by Cong Le on 12/17/24.
//
//
//  ObjCViewController.h

#import <TargetConditionals.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
typedef UIViewController MyViewController;
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
typedef NSViewController MyViewController;
#endif

// Type alias for MyView
#if TARGET_OS_IOS
typedef UIView MyView;
#elif TARGET_OS_OSX
typedef NSView MyView;
#endif

@interface SharedLogic : NSObject  // Located in the 'Shared' directory
- (void)platformSpecificOperation;
@end

@implementation SharedLogic
- (void)platformSpecificOperation {
#if TARGET_OS_IOS
    // iOS-specific implementation (e.g., UIKit calls)
#elif TARGET_OS_OSX
    // macOS-specific implementation (e.g., AppKit calls)
#endif
}
@end

@interface ObjCViewController : MyViewController

@end
