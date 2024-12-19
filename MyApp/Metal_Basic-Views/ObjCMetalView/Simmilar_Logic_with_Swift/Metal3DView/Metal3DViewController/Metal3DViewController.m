//
//  ViewController.m
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//
// Source: https://github.com/metal-by-example/sample-code/blob/master/objc/04-DrawingIn3D/DrawingIn3D/ViewController.m
//

#import "Metal3DViewController.h"
#import "CAMetal3DView.h"
#import "RendererFor3DView.h"

@interface Metal3DViewController ()

@property (nonatomic, strong) CAMetal3DView *metalView;
@property (nonatomic, strong) RendererFor3DView *renderer;

@end

@implementation Metal3DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the Metal device
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        NSLog(@"Metal is not supported on this device");
        return;
    }
    
    // Create the Metal view
    self.metalView = [[CAMetal3DView alloc] initWithFrame:self.view.bounds device:device];
    self.metalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.metalView.preferredFramesPerSecond = 60;
    
    // Set the renderer as the delegate
    self.renderer = [[RendererFor3DView alloc] initWithDevice:device];
    self.metalView.delegate = self.renderer;
    
    [self.view addSubview:self.metalView];
}

@end
