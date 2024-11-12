//
//  AppDelegate.m
//  MyApp
//
//  Created by Cong Le on 11/1/24.
//

//#import "AppDelegate.h"
//
//@implementation AppDelegate
//
//// Called when the application has finished launching.
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    NSLog(@"Objective-C: application:didFinishLaunchingWithOptions:");
//    // Override point for customization after application launch.
//    return YES;
//}
//
//// Called when the application becomes active.
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    NSLog(@"Objective-C: applicationDidBecomeActive:");
//}
//
//// Called when the application is about to resign active state.
//- (void)applicationWillResignActive:(UIApplication *)application {
//    NSLog(@"Objective-C: applicationWillResignActive:");
//}
//
//// Called when the application entered background.
//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    NSLog(@"Objective-C: applicationDidEnterBackground:");
//}
//
//// Called when the application will enter foreground.
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//    NSLog(@"Objective-C: applicationWillEnterForeground:");
//}
//
//// Called when the application is about to terminate.
//- (void)applicationWillTerminate:(UIApplication *)application {
//    NSLog(@"Objective-C: applicationWillTerminate:");
//}
//
//@end

// AppDelegate.m
#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"Objective-C: application:didFinishLaunchingWithOptions:");
    [self logLifecycleEvent:@"didFinishLaunching"];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Objective-C: applicationDidBecomeActive:");
    [self logLifecycleEvent:@"applicationDidBecomeActive"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"Objective-C: applicationWillResignActive:");
    [self logLifecycleEvent:@"applicationWillResignActive"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Objective-C: applicationDidEnterBackground:");
    [self logLifecycleEvent:@"applicationDidEnterBackground"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"Objective-C: applicationWillEnterForeground:");
    [self logLifecycleEvent:@"applicationWillEnterForeground"];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Objective-C: applicationWillTerminate:");
    [self logLifecycleEvent:@"applicationWillTerminate"];
}

// Example Objective-C function implementation
- (void)logLifecycleEvent:(NSString *)eventName {
    NSLog(@"Objective-C: Lifecycle Event - %@", eventName);
}

@end

