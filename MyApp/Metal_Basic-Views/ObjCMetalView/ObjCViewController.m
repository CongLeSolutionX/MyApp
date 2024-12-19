//
//  ObjCViewController.m
//  MyApp
//
//  Created by Cong Le on 12/17/24.
//
//
//  ObjCViewController.m

#import "ObjCViewController.h"
#import "ObjCMetalView.h"

//#if TARGET_OS_IOS
//// No additional imports needed
//#elif TARGET_OS_OSX
//#import <QuartzCore/QuartzCore.h> // For CALayer
//#endif

// MARK: - Interface of ObjCViewController
@interface ObjCViewController ()
@property (nonatomic, strong) ObjCMetalView *metalView;
@end

// MARK: -  Implementation of ObjCViewController
@implementation ObjCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#if TARGET_OS_IOS
    // Initialize the metal view
    self.metalView = [[ObjCMetalView alloc] initWithFrame:self.view.bounds];

    // Set autoresizingMask if not using Auto Layout
    self.metalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // Add the metal view as a subview
    [self.view addSubview:self.metalView];

#elif TARGET_OS_OSX
    // Initialize the metal view
    self.metalView = [[ObjCMetalView alloc] initWithFrame:self.view.bounds];

    // Set autoresizingMask if not using Auto Layout
    self.metalView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    // Add the metal view as a subview
    [self.view addSubview:self.metalView];

    // Adjust view layer settings if necessary
    [self.view setWantsLayer:YES];
#endif
}

#if TARGET_OS_IOS
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // Ensure the metal view's frame matches the view controller's view
    self.metalView.frame = self.view.bounds;
}
#elif TARGET_OS_OSX
- (void)viewDidLayout {
    [super viewDidLayout];

    // Ensure the metal view's frame matches the view controller's view
    self.metalView.frame = self.view.bounds;
}
#endif

#if TARGET_OS_IOS
- (BOOL)prefersStatusBarHidden {
    return YES;
}
#endif

@end
