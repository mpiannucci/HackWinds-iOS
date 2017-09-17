//
//  SettingsViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 2/24/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "SettingsViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *showDetailedForecastSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    [self loadSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadSettings {
    // Get the settings object
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults synchronize];
    
    // Update the switch to match if detailed forecast info is enabled
    [self.showDetailedForecastSwitch setOn:[defaults boolForKey:@"ShowDetailedForecastInfo"]];
    
}

- (IBAction)acceptSettingsClick:(id)sender {
    // For now just make it go away
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)contactDevClicked:(id)sender {
    // Open the compose view using the mailto url
    NSString *recipients = @"mailto:rhodysurf13@gmail.com?subject=HackWinds for iOS";
    NSString *email = [NSString stringWithFormat:@"%@", recipients];
    email = [email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (IBAction)showDisclaimerClicked:(id)sender {
    // Construct and show the disclaimer alert
    NSString* disclaimer = @"I do not own nor claim to own either the wave camera images or the tide information displayed in this app. This app is simply an interface to make checking the waves easier for surfers when using a phone. I am speifically operating within the user licensing for the Wunderground and WarmWinds API's.";
    UIAlertController *disclaimerController = [UIAlertController alertControllerWithTitle:@"Disclaimer"
                                                                                  message:disclaimer
                                                                           preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil];
    [disclaimerController addAction:doneAction];
    [self presentViewController:disclaimerController animated:YES completion:nil];
}

- (IBAction)rateAppClicked:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id945847570"]];
}

- (IBAction)showDetailedForecastInfoChanged:(id)sender {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaults setBool:[sender isOn] forKey:@"ShowDetailedForecastInfo"];
    [defaults synchronize];
}

@end
