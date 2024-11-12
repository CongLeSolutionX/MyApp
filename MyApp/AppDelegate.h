//
//  AppDelegate.h
//  MyApp
//
//  Created by Cong Le on 11/1/24.
//

//#import <UIKit/UIKit.h>
//
//@interface AppDelegate : UIResponder <UIApplicationDelegate>
//
//@property (strong, nonatomic) UIWindow *window;
//
//@end



// AppDelegate.h
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Example Objective-C function
- (void)logLifecycleEvent:(NSString *)eventName;

@end
