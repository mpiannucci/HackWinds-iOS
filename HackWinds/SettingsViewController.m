//
//  SettingsViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 2/24/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "SettingsViewController.h"
#include "Constants.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *forecastLocationLabel;

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Get the location and set the cell to reflect it
    [self.forecastLocationLabel setText:[defaults objectForKey:@"ForecastLocation"]];
}

- (IBAction)acceptSettingsClick:(id)sender {
    // For now just make it go away
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeForecastLocationClicked:(id)sender {
    UIActionSheet *locationActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Forecast Location"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:FORECAST_LOCATIONS];
    // Show the action sheet
    [locationActionSheet showInView:self.view];
}

- (IBAction)contactDevClicked:(id)sender {
    // Open the compose view using the mailto url
    NSString *recipients = @"mailto:rhodysurf13@gmail.com?subject=HackWinds for iOS";
    NSString *email = [NSString stringWithFormat:@"%@", recipients];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (IBAction)showDisclaimerClicked:(id)sender {
    // Construct and show the disclaimer alert
    NSString* disclaimer = @"I do not own or claim to own neither the wave camera images or the forecast information displayed in this app. This app is simply an interface to make checking the waves easier for surfers when using a phone. I am speifically operating within the user licensing for the MagicSeaweed and Wunderground API's.";
    UIAlertView *disclaimerMessage = [[UIAlertView alloc] initWithTitle:@"Disclaimer"
                                                    message:disclaimer
                                                   delegate:nil
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [disclaimerMessage show];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (buttonIndex != [actionSheet numberOfButtons] - 1) {
        // If the user selects a location, set the settings key to the new location
        [defaults setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:@"ForecastLocation"];
        [defaults synchronize];
        [self loadSettings];
    } else {
        NSLog(@"Location change cancelled, keep location at %@", [defaults objectForKey:@"ForecastLocation"]);
    }
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
