//
//  ViewController.m
//  MyApp
//
//  Created by Cong Le on 12/19/24.
//

#import "Metal2DViewController.h"
#import "CAMetal2DView.h"
#import <Metal/Metal.h>

@interface Metal2DViewController ()

@property (nonatomic, strong) CAMetal2DView *metal2DView;

@end

@implementation Metal2DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the Metal device and command queue
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    id<MTLCommandQueue> queue = [device newCommandQueue];
    
    // Initialize the CAMetal2DView
    self.metal2DView = [[CAMetal2DView alloc] initWithDevice:device queue:queue];
    self.metal2DView.frame = self.view.bounds;
    self.metal2DView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Add the metal view to the view controller's view
    [self.view addSubview:self.metal2DView];
}

@end
