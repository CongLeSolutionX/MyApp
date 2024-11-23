//
//  LifecycleObjCViewController.m
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//


#import "LifecycleObjCViewController.h"

@interface LifecycleObjCViewController ()

// Define any properties or UI elements here
@property (strong, nonatomic) UILabel *statusLabel;

@end

@implementation LifecycleObjCViewController

#pragma mark - Initialization

// 1. initWithNibName:bundle:
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    NSLog(@"initWithNibName:bundle: called");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization can be done here
        NSLog(@"LifecycleViewController initialized with nib name: %@ and bundle: %@", nibNameOrNil, nibBundleOrNil);
    }
    return self;
}

#pragma mark - View Lifecycle Methods

// 2. loadView
- (void)loadView {
    NSLog(@"loadView called");

    // Create a root view
    UIView *rootView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    rootView.backgroundColor = [UIColor systemTealColor];

    // Initialize and configure a label
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 200, rootView.bounds.size.width - 100, 50)];
    self.statusLabel.text = @"View is loading...";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:18];

    // Add the label to the root view
    [rootView addSubview:self.statusLabel];

    // Assign the root view to the view controller's view property
    self.view = rootView;
}

// 3. viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad called");

    // Additional setup after loading the view
    self.statusLabel.text = @"View did load.";

    // Example: Setting up a button to demonstrate user interaction
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    actionButton.frame = CGRectMake(100, 300, self.view.bounds.size.width - 200, 50);
    [actionButton setTitle:@"Tap Me" forState:UIControlStateNormal];
    [actionButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:actionButton];
}

// 4. viewWillAppear:
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear: called");

    // Update UI elements or data before the view appears
    self.statusLabel.text = @"View will appear.";
}

// 5. viewWillLayoutSubviews
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    NSLog(@"viewWillLayoutSubviews called");

    // Adjust layout before subviews are laid out
}

// 6. viewDidLayoutSubviews
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSLog(@"viewDidLayoutSubviews called");

    // Finalize layout after subviews have been laid out
}

// 7. viewDidAppear:
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear: called");

    // Start animations or tracking view appearance
    self.statusLabel.text = @"View did appear.";
}

// 8. User Interaction Handler
- (void)buttonTapped:(UIButton *)sender {
    NSLog(@"Button was tapped by the user.");
    self.statusLabel.text = @"Button was tapped!";
}

// 9. viewWillDisappear:
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear: called");

    // Prepare for the view disappearing (e.g., save state)
    self.statusLabel.text = @"View will disappear.";
}

// 10. viewDidDisappear:
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear: called");

    // Clean up resources or stop services that don't need to run when the view isn't visible
    self.statusLabel.text = @"View did disappear.";
}

#pragma mark - Memory Management

// 11. dealloc
- (void)dealloc {
    NSLog(@"dealloc called");

    // Clean up any resources, observers, or notifications
    // Example: [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
