//
//  IsoCameraViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 5/4/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "IsoCameraViewController.h"
#import "AsyncImageView.h"

@interface IsoCameraViewController ()

@property (weak, nonatomic) IBOutlet AsyncImageView *camImage;
@property (weak, nonatomic) IBOutlet UISwitch *autoReloadSwitch;
@property (weak, nonatomic) IBOutlet UILabel *refreshIntervalLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fullScreenCamImage;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenExitButton;

@end

@implementation IsoCameraViewController {
    NSURL *cameraURL;
    NSInteger refreshInterval;
    BOOL shouldHideStatusBar;
    BOOL isFullScreen;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the navigation controller
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    // Initialize the full screen to not be full screen
    [self.fullScreenExitButton setHidden:YES];
    [self.fullScreenCamImage setHidden:YES];
    isFullScreen = NO;
    shouldHideStatusBar = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    // Don't cache anything so we can reload a bunch
    AsyncImageLoader *imageLoaderInstance = [AsyncImageLoader sharedLoader];
    imageLoaderInstance.cache = nil;
    
    // Register for image loaded notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFullScreenImage) name:@"AsyncImageLoadDidFinish" object:nil];
    
    if ([self.Camera isEqualToString:@"Town Beach South"]) {
        // On the Narragansett cam the update interval is 30 seconds
        refreshInterval = 35.0;
    } else {
        // Otherwise relaod every 5 seconds
        refreshInterval = 3.0;
    }
    
    [self updateRefreshLabel];
    
    // Set the navigation title
    self.navigationItem.title = self.Camera;
    
    // Load the first image
    [self loadCamImage];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Restore cache to default as the view exits
    AsyncImageLoader *imageLoaderInstance = [AsyncImageLoader sharedLoader];
    imageLoaderInstance.cache = [AsyncImageLoader defaultCache];
    
    // Remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCamera:(NSString *)camera forLocation:(NSString *)location {
    self.Camera = camera;
    self.Location = location;
    
    // Load locations from file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CameraLocations"
                                                     ofType:@"plist"];
    NSDictionary *cameraURLs = [NSDictionary dictionaryWithContentsOfFile:path];
    cameraURL = [NSURL URLWithString:[[cameraURLs objectForKey:self.Location] objectForKey:self.Camera]];
}

- (void)loadCamImage {
    [self.camImage setImageURL:cameraURL];
    
    if (![self.autoReloadSwitch isOn]) {
        // If the switch is deactivated, dont fire the timer
        return;
    }
    
    // Fire the refresh timer
    [NSTimer scheduledTimerWithTimeInterval:refreshInterval
                                     target:self
                                   selector:@selector(loadCamImage)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)updateRefreshLabel {
    // Show the refresh label if auto refresh is turned on
    if ([self.autoReloadSwitch isOn]) {
        [self.refreshIntervalLabel setHidden:NO];
        [self.refreshIntervalLabel setText:[NSString stringWithFormat:@"Refresh interval is %ld seconds", (long)refreshInterval]];
    } else {
        [self.refreshIntervalLabel setHidden:YES];
    }
}

- (void)updateFullScreenImage {
    if (!isFullScreen) {
        return;
    }
    
    // Update the full screen image with a landscape version of the original imageview image
    UIImage *imageCopy = self.camImage.image;
    self.fullScreenCamImage.image = [[UIImage alloc] initWithCGImage: imageCopy.CGImage
                                                               scale: 1.0
                                                         orientation: UIImageOrientationRight];
}

- (IBAction)autoReloadSwitchChange:(id)sender {
    [self updateRefreshLabel];
}

- (IBAction)fullScreenClick:(id)sender {
    // Set the full screen flag
    isFullScreen = YES;
    
    // Set the initial full screen image
    [self updateFullScreenImage];
    
    // Hide the status bar and nav bar
    shouldHideStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:YES];

    // Show the full screen image and the close button
    [self.fullScreenCamImage setHidden:NO];
    [self.fullScreenExitButton setHidden:NO];
}

- (IBAction)exitButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)fullScreenExitClick:(id)sender {
    // Show the status bar and nav bar
    shouldHideStatusBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:NO];
    
    // Hide the close button and the full screen image
    [self.fullScreenCamImage setHidden:YES];
    [self.fullScreenExitButton setHidden:YES];
    isFullScreen = NO;
}

- (BOOL)prefersStatusBarHidden {
    return shouldHideStatusBar;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
