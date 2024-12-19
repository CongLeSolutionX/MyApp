//
//  ViewController.m
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

// ViewController.m

#import "ViewController.h"
#import "CAMetal3DView.h"
#import "CubeRenderer.h"

@interface ViewController ()

@property (nonatomic, strong) CAMetal3DView *metalView;
@property (nonatomic, strong) CubeRenderer *renderer;

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
    
    // Initialize the renderer
    self.renderer = [[CubeRenderer alloc] initWithDevice:device];
    if (!self.renderer) {
        NSLog(@"Failed to initialize renderer");
        return;
    }
    
    // Create the Metal view
    self.metalView = [[CAMetal3DView alloc] initWithFrame:self.view.bounds
                                                   device:device
                                                 renderer:self.renderer];
    self.metalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.metalView];
}

@end
