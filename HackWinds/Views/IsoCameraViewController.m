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

@end

@implementation IsoCameraViewController {
    NSURL *cameraURL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the navigation controller
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = self.Camera;
    
    [self loadCamImage];
}

- (void)viewWillDisappear:(BOOL)animated {
    
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
}

- (IBAction)reloadButtonClick:(id)sender {
    
}

- (IBAction)autoReloadSwitchChange:(id)sender {
    
}

- (IBAction)fullScreenClick:(id)sender {
    
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
