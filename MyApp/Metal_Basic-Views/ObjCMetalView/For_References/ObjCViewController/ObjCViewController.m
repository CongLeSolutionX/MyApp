//
//  ObjCViewController.m
//  MyApp
//
//  Created by Cong Le on 12/17/24.
//
//
//  ObjCViewController.m

#import "ObjCViewController.h"
#import "ObjCMetalPlainView.h"
#import "ObjCMetal2DView.h"

// MARK: - Interface of ObjCViewController
@interface ObjCViewController ()
//@property (nonatomic, strong) ObjCMetalPlainView *metalPlainView;
@property (nonatomic, strong) ObjCMetal2DView *metal2DView;
@end

// MARK: -  Implementation of ObjCViewController
@implementation ObjCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#if TARGET_OS_IOS
    // Initialize the metal view
    self.metal2DView = [[ObjCMetal2DView alloc] initWithFrame:self.view.bounds];

    // Set autoresizingMask if not using Auto Layout
    self.metal2DView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // Add the metal view as a subview
    [self.view addSubview:self.metal2DView];

#elif TARGET_OS_OSX
    // Initialize the metal view
    self.metalView = [[ObjCMetalPlainView alloc] initWithFrame:self.view.bounds];

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
    self.metal2DView.frame = self.view.bounds;
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
