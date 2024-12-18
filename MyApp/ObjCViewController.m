//
//  ViewController.m
//  MyApp
//
//  Created by Cong Le on 12/17/24.
//
// ObjCViewController.m
// ObjCViewController.m

#import "ObjCViewController.h"
#import "ObjCMetalView.h"

@interface ObjCViewController ()

@property (nonatomic, strong) ObjCMetalView *metalView;

@end

@implementation ObjCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the metal view
    self.metalView = [[ObjCMetalView alloc] initWithFrame:self.view.bounds];
    
    // Optionally set autoresizingMask if not using Auto Layout
    self.metalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Add the metal view as a subview
    [self.view addSubview:self.metalView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Ensure the metal view's frame matches the view controller's view
    self.metalView.frame = self.view.bounds;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
