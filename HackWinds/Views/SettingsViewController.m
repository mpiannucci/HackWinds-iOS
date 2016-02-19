//
//  SettingsViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 2/24/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "SettingsViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>

static const int BUOY_TAG = 2;

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *defaultBuoyLocationLabel;

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
    
    // Get the locations and set the cell to reflect it
    [self.defaultBuoyLocationLabel setText:[defaults objectForKey:@"DefaultBuoyLocation"]];
}

- (IBAction)acceptSettingsClick:(id)sender {
    // For now just make it go away
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeDefaultBuoyLocationClicked:(id)sender {
    UIActionSheet *locationActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Default Buoy Location"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:BUOY_LOCATIONS];
    // Show the action sheet
    locationActionSheet.tag = BUOY_TAG;
    [locationActionSheet setTintColor:HACKWINDS_BLUE_COLOR];
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
    [disclaimerMessage setTintColor:HACKWINDS_BLUE_COLOR];
    [disclaimerMessage show];
}

- (IBAction)rateAppClicked:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id945847570"]];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    
    if (actionSheet.tag == BUOY_TAG) {
        if (buttonIndex != [actionSheet numberOfButtons] - 1) {
            // If the user selects a location, set the settings key to the new location
            [defaults setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:@"DefaultBuoyLocation"];
            [defaults setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:@"BuoyLocation"];
            [defaults synchronize];
            
            // Tell everyone the default buoy location has updated
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:DEFAULT_BUOY_LOCATION_CHANGED_TAG
                 object:self];
            });
            
            // Tell everyone the buoy location has updated
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:BUOY_LOCATION_CHANGED_TAG
                 object:self];
            });
            
            [self loadSettings];
        } else {
            NSLog(@"Buoy location change cancelled, keep location at %@", [defaults objectForKey:@"DefaultBuoyLocation"]);
        }
    } else {
        NSLog(@"Invalid action sheet somehow");
    }
    
}

@end
