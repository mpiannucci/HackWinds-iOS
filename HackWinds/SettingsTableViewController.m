//
//  SettingsTableViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 1/17/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController {
    __block NSString* location;
}

@synthesize locationLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)locationButtonClick:(id)sender {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Pick Forecast Location"
                                          message:@"Choose your desired forecast location"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *ntbAction = [UIAlertAction
                                   actionWithTitle:@"Narragansett Town Beach"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [self updateForecastLocation:@"Narragansett Town Beach"];
                                   }];
    UIAlertAction *pjAction = [UIAlertAction
                               actionWithTitle:@"Point Judith"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [self updateForecastLocation:@"Point Judith"];
                               }];
    UIAlertAction *secBeachAction = [UIAlertAction
                                     actionWithTitle:@"Second Beach"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [self updateForecastLocation:@"Second Beach"];
                                     }];
    UIAlertAction *matunuckAction = [UIAlertAction
                                     actionWithTitle:@"Matunuck"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [self updateForecastLocation:@"Matunuck"];
                                     }];
    UIAlertAction *cancelAction = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleCancel
                                     handler:^(UIAlertAction * action)
                                     {
                                         // Dont set the location, canceled
                                     }];
    
    [alertController addAction:ntbAction];
    [alertController addAction:pjAction];
    [alertController addAction:secBeachAction];
    [alertController addAction:matunuckAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateForecastLocation:(NSString*)newLocation {
    NSLog(@"Changed location to %@", newLocation);
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
