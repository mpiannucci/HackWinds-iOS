//
//  AlternateCamerasViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 5/4/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "AlternateCamerasViewController.h"
#import "IsoCameraViewController.h"

@interface AlternateCamerasViewController ()

@end

@implementation AlternateCamerasViewController {
    NSDictionary *cameraURLs;
    NSArray *locationKeys;
    NSArray *cameraKeys;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    cameraURLs = [defaults objectForKey:@"CameraLocations"];
    locationKeys = [cameraURLs allKeys];
    
    NSMutableArray *allCameras = [[NSMutableArray alloc] init];
    for (NSString *key in locationKeys) {
        [allCameras addObject:[[cameraURLs objectForKey:key] allKeys]];
    }
    cameraKeys = [NSArray arrayWithArray:allCameras];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeViewClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return cameraURLs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger nRows = 0;
    if (section < cameraURLs.count) {
        nRows = [[cameraURLs objectForKey:locationKeys[section]] count];
        if ([locationKeys[section] isEqualToString:@"Narragansett"]) {
            nRows -= 2;
        }
    }
    return nRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cameraLocationItem" forIndexPath:indexPath];
    
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:89];
    
    NSInteger row = indexPath.row;
    
    if ((indexPath.section < locationKeys.count) &&
        (indexPath.row < [[cameraKeys objectAtIndex:indexPath.section] count])) {
        if ([locationKeys[indexPath.section] isEqualToString:@"Narragansett"]) {
            row += 2;
        }
        [locationLabel setText:[[cameraKeys objectAtIndex:indexPath.section] objectAtIndex:row]];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self nameOfSection:section];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)nameOfSection:(NSInteger)section {
    return locationKeys[section];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"altCameraSegue"]) {
        // Get the row of the table that was selected
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        IsoCameraViewController *cameraView = segue.destinationViewController;
        
        // Get the cell that was selected so we can get the name
        UILabel *locationLabel = (UILabel*)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:89];
        NSString *location = [self nameOfSection:indexPath.section];
        
        [cameraView setCamera:locationLabel.text forLocation:location];
    }
}

@end
