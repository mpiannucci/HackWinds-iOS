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
@property (weak, nonatomic) IBOutlet UILabel *extraCameraInfo;
@end

@implementation IsoCameraViewController {
    Camera *camera;
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
    isFullScreen = NO;
    [self.extraCameraInfo setHidden:YES];
    
    // Set the state of the auto reload switch
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.autoReloadSwitch setOn:[defaults boolForKey:@"CamAutoReload"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Don't cache anything so we can reload a bunch
    AsyncImageLoader *imageLoaderInstance = [AsyncImageLoader sharedLoader];
    imageLoaderInstance.cache = nil;
    
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
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCamera:(NSString *)camName forLocation:(NSString *)locName {
    self.cameraName = camName;
    self.locationName = locName;
    
    CameraModel *cameraModel = [CameraModel sharedModel];
    camera = [cameraModel cameraForLocation:self.locationName camera:self.cameraName];
}

- (void)loadCamImage {
    [self.camImage setImageURL:camera.imageURL];
    
    if (![self.autoReloadSwitch isOn]) {
        // If the switch is deactivated, dont fire the timer
        return;
    } else if (![camera isRefreshable]) {
        // Disable refreshing
        [self.autoReloadLabel setHidden:YES];
        [self.autoReloadSwitch setHidden:YES];
        return;
    }
    
    // Fire the refresh timer
    [NSTimer scheduledTimerWithTimeInterval:[camera isRefreshable]
                                     target:self
                                   selector:@selector(loadCamImage)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)updateRefreshLabel {
    // Show the refresh label if auto refresh is turned on
    if ([self.autoReloadSwitch isOn]) {
        [self.refreshIntervalLabel setHidden:NO];
        [self.refreshIntervalLabel setText:[NSString stringWithFormat:@"Refresh interval is %ld seconds", (long)[camera getRefreshDuration]]];
    } else {
        [self.refreshIntervalLabel setHidden:YES];
    }
}

- (IBAction)autoReloadSwitchChange:(id)sender {
    // Update the auto reload settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender isOn] forKey:@"CamAutoReload"];
    [defaults synchronize];
    
    // Update the refresh label
    [self updateRefreshLabel];
}

- (IBAction)exitButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return isFullScreen;
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Code here will execute after the rotation has finished.
        // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        
    }];
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
