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

- (void) changeDefaultBuoyLocationSetting:(NSString*)newLocation;
- (void) activatePremiumContentSetting;
- (void) loginUser:(NSString*) username;

@property (weak, nonatomic) IBOutlet UIButton *activatePremiumContentButton;
@property (weak, nonatomic) IBOutlet UIButton *changeDefaultBuoyButton;

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
    [self.changeDefaultBuoyButton setTitle:[NSString stringWithFormat:@"Default Buoy Location: %@", [defaults objectForKey:@"DefaultBuoyLocation"]] forState:UIControlStateNormal];
    
    BOOL loggedIn = [defaults boolForKey:@"LoggedIn"];
    // TODO: Change the state based on log in
}

- (IBAction)acceptSettingsClick:(id)sender {
    // For now just make it go away
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeDefaultBuoyLocationClicked:(id)sender {
    UIAlertController *locationActionSheet = [UIAlertController alertControllerWithTitle:@"Default Buoy Location"
                                                                          message:@"Choose the buoy location to show by default"
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *biLocationAction = [UIAlertAction actionWithTitle:@"Block Island"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self changeDefaultBuoyLocationSetting:action.title];
                                                             }];
    UIAlertAction *mtkLocationAction = [UIAlertAction actionWithTitle:@"Montauk"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self changeDefaultBuoyLocationSetting:action.title];
                                                             }];
    UIAlertAction *nantucketLocationAction = [UIAlertAction actionWithTitle:@"Nantucket"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [self changeDefaultBuoyLocationSetting:action.title];
                                                              }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    // Add the actions
    [locationActionSheet addAction:biLocationAction];
    [locationActionSheet addAction:mtkLocationAction];
    [locationActionSheet addAction:nantucketLocationAction];
    [locationActionSheet addAction:cancelAction];
    
    // Show the action sheet
    [self presentViewController:locationActionSheet animated:YES completion:nil];
}

- (IBAction)loginLogoutClicked:(id)sender {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    BOOL loggedIn = [defaults boolForKey:@"LoggedIn"];
    
    if (loggedIn) {
        UIAlertController *logoutDialogController = [UIAlertController alertControllerWithTitle:@"Log Out"
                                                                                        message:@"Are you sure you want to log out?"
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *logOutAction = [UIAlertAction actionWithTitle:@"Log Out"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            // TODO
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        // Add all of the actions
        [logoutDialogController addAction:logOutAction];
        [logoutDialogController addAction:cancelAction];
        
        // Show the controller
        [self presentViewController:logoutDialogController animated:YES completion:nil];
        
    } else {
        UIAlertController *loginDialogController = [UIAlertController alertControllerWithTitle:@"Log in to HackWinds"
                                                                                   message:@"Enter your email to log in"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        __block UITextField *inputEmail;
        [loginDialogController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Email";
            inputEmail = textField;
        }];
    
        UIAlertAction *logInAction = [UIAlertAction actionWithTitle:@"Log In"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                if (inputEmail == nil) {
                                                                    return;
                                                                }
                                                            
                                                                [self loginUser:inputEmail.text];
                                                            }];
    
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
    
        // Add all of the input
        [loginDialogController addAction:logInAction];
        [loginDialogController addAction:cancelAction];
    
        // Show the controller
        [self presentViewController:loginDialogController animated:YES completion:nil];
    }
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
    NSString* disclaimer = @"I do not own or claim to own neither the wave camera images or the tide information displayed in this app. This app is simply an interface to make checking the waves easier for surfers when using a phone. I am speifically operating within the user licensing for the Wunderground and WarmWinds API's.";
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

- (void) changeDefaultBuoyLocationSetting:(NSString*)newLocation {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    
    // Set the value in the settings
    [defaults setObject:newLocation forKey:@"DefaultBuoyLocation"];
    [defaults setObject:newLocation forKey:@"BuoyLocation"];
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
    
    // Reload the settings
    [self loadSettings];
}

- (void) activatePremiumContentSetting {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    
    // Set the value in the settings
    [defaults setBool:YES forKey:@"ShowPremiumContent"];
    
    // Activate premium things!!
    [[CameraModel sharedModel] forceFetchCameraURLs];
    
    // Reload the interface
    [self loadSettings];
}

- (void) loginUser:(NSString*)username {
    NSURL *loginURL = [NSURL URLWithString:@"https://mpiannucci.appspot.com/hackwinds_login"];
    NSString *loginData = [NSString stringWithFormat:@"username=%@", username];
    
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginURL];
    loginRequest.HTTPMethod = @"POST";
    loginRequest.HTTPBody = [loginData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *loginTask = [[NSURLSession sharedSession] dataTaskWithRequest:loginRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data == NULL) {
            // TODO: Show failure
            return;
        } else if (error != NULL) {
            // TODO: Show failure
            return;
        }
        
        NSError *jsonError;
        NSDictionary *loginData = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:kNilOptions
                                      error:&error];
        
        if ((loginData == nil) || (jsonError != nil)) {
            return;
        }
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
        [defaults synchronize];
        
        BOOL isPremium = [loginData valueForKey:@"premium"];
        [defaults setBool:isPremium forKey:@"ShowPremiumContent"];
        if (isPremium) {
            CameraModel *model = [CameraModel sharedModel];
            [model forceFetchCameraURLs];
        }
    }];
    
    [loginTask resume];
}

@end
