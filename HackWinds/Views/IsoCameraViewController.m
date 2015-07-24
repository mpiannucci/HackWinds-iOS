//
//  IsoCameraViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 5/4/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//
#define POINT_JUDITH_STATIC_IMAGE [NSURL URLWithString:@"http://www.asergeev.com/pictures/archives/2004/372/jpeg/20.jpg"]

#import "IsoCameraViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AsyncImageView.h"
#import <HackWindsDataKit/HackWindsDataKit.h>

@interface IsoCameraViewController ()

// UI Properties
@property (weak, nonatomic) IBOutlet AsyncImageView *camImage;
@property (weak, nonatomic) IBOutlet UILabel *autoReloadLabel;
@property (weak, nonatomic) IBOutlet UISwitch *autoReloadSwitch;
@property (weak, nonatomic) IBOutlet UILabel *refreshIntervalLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fullScreenCamImage;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenExitButton;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenViewButton;
@property (strong, nonatomic) MPMoviePlayerController *streamPlayer;
@property (weak, nonatomic) IBOutlet UILabel *extraCameraInfo;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayButton;
@end

@implementation IsoCameraViewController {
    Camera *camera;
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
    
    // Initialize the play button to be hidden
    [self.videoPlayButton setHidden:YES];
    [self.extraCameraInfo setHidden:YES];
    
    // Set the state of the auto reload switch
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.autoReloadSwitch setOn:[defaults boolForKey:@"CamAutoReload"]];
}

- (void)viewWillAppear:(BOOL)animated {
    // Don't cache anything so we can reload a bunch
    AsyncImageLoader *imageLoaderInstance = [AsyncImageLoader sharedLoader];
    imageLoaderInstance.cache = nil;
    
    // Register for image loaded notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFullScreenImage)
                                                 name:@"AsyncImageLoadDidFinish"
                                               object:nil];
    
    if ([self.cameraName isEqualToString:@"Town Beach South"]) {
        // On the Narragansett cam the update interval is 30 seconds
        refreshInterval = 35.0;
    } else {
        // Otherwise relaod every 5 seconds
        refreshInterval = 3.0;
    }
    
    [self updateRefreshLabel];
    
    // Set the navigation title
    self.navigationItem.title = self.cameraName;
    
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

- (void)setCamera:(NSString *)camName forLocation:(NSString *)locName {
    self.cameraName = camName;
    self.locationName = locName;
    
    CameraModel *cameraModel = [CameraModel sharedModel];
    camera = [[cameraModel.cameraURLS objectForKey:self.locationName] objectForKey:self.cameraName];
}

- (void)loadCamImage {
    [self.camImage setImageURL:camera.ImageURL];
    
    if (![[camera.VideoURL absoluteString] isEqualToString:@""]) {
        [self.autoReloadSwitch setOn:NO];
        [self.autoReloadSwitch setHidden:YES];
        [self.autoReloadLabel setHidden:YES];
        [self.refreshIntervalLabel setHidden:YES];
        [self.fullScreenViewButton setHidden:YES];
        [self.videoPlayButton setHidden:NO];
        [self.extraCameraInfo setHidden:NO];
        [self.extraCameraInfo setNumberOfLines:0];
        [self.extraCameraInfo setText:camera.Info];
        [self.extraCameraInfo sizeToFit];
    }
    
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
    // Update the auto reload settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender isOn] forKey:@"CamAutoReload"];
    [defaults synchronize];
    
    // Update the refresh label
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
    // Reset the full screen flag
    isFullScreen = NO;
    
    // Show the status bar and nav bar
    shouldHideStatusBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:NO];
    
    // Hide the close button and the full screen image
    [self.fullScreenCamImage setHidden:YES];
    [self.fullScreenExitButton setHidden:YES];
}

- (IBAction)videoPlayButtonClick:(id)sender {
    // Get the screen size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    self.streamPlayer = [[MPMoviePlayerController alloc] initWithContentURL:camera.VideoURL];
    [self.streamPlayer.view setFrame:CGRectMake(0, 0, screenWidth, 255)];
    [self.view addSubview:self.streamPlayer.view];
    
    // Set a listener for the video playback finishing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.streamPlayer];
    
    // Load the stream and play it
    [self.streamPlayer prepareToPlay];
    [self.streamPlayer play];
    
    // Hide the async holder image
    [self.camImage setHidden:YES];
}

- (void)videoPlayBackDidFinish:(NSNotification*)notification {
    // Remove the notification for the player
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.streamPlayer];
    // Show the holder image again
    [self.camImage setHidden:NO];
    
    // Remove the player from the superview
    [self.streamPlayer.view removeFromSuperview];
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
