//
//  ViewController.m
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//
// ViewController.m

#import "ViewController.h"
#import "MBEMetalView.h"
#import "MBERenderer.h"

@interface ViewController ()

@property (nonatomic, strong) MBEMetalView *metalView;
@property (nonatomic, strong) MBERenderer *renderer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the Metal device
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        NSLog(@"Metal is not supported on this device");
        return;
    }
    
    // Create the Metal view
    self.metalView = [[MBEMetalView alloc] initWithFrame:self.view.bounds device:device];
    self.metalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.metalView.preferredFramesPerSecond = 60;
    
    // Set the renderer as the delegate
    self.renderer = [[MBERenderer alloc] initWithDevice:device];
    self.metalView.delegate = self.renderer;
    
    [self.view addSubview:self.metalView];
}

@end
