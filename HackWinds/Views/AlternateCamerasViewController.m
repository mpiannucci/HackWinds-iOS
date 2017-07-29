//
//  AlternateCamerasViewController.m
//  HackWinds
//
//  Created by Matthew Iannucci on 5/4/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import "AlternateCamerasViewController.h"
#import "IsoCameraViewController.h"
#import <HackWindsDataKit/HackWindsDataKit.h>

@interface AlternateCamerasViewController()

- (BOOL)shouldShowISOCameraView:(NSString*) locationName :(NSString*) cameraName;

@end

@implementation AlternateCamerasViewController {
    CameraModel *cameraModel;
    NSArray *locationKeys;
    NSArray *cameraKeys;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    cameraModel = [CameraModel sharedModel];
    locationKeys = [cameraModel.cameraURLS allKeys];
    
    NSMutableArray *tempCameraKeys = [[NSMutableArray alloc] init];
    for (NSString *location in locationKeys) {
        [tempCameraKeys addObject:[[[cameraModel cameraURLS] objectForKey:location] allKeys]];
    }
    cameraKeys = [NSArray arrayWithArray:tempCameraKeys];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeViewClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldShowISOCameraView:(NSString*) locationName :(NSString*) cameraName {
    Camera* camera = [cameraModel cameraForLocation:locationName camera:cameraName];
    if (camera == nil) {
        return NO;
    }
    
    if ([[camera.videoURL absoluteString] isEqualToString:@""] && [[camera.webURL absoluteString] isEqualToString:@""] && ![[camera.imageURL absoluteString] isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[CameraModel sharedModel] cameraURLS] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger nRows = 0;
    if (section < [locationKeys count]) {
        nRows += [[[cameraModel cameraURLS] objectForKey:[locationKeys objectAtIndex:section]] count];
    }
    return nRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cameraLocationItem" forIndexPath:indexPath];
    
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:89];
    
    NSInteger row = indexPath.row;
    
    if ((indexPath.section < locationKeys.count) &&
        (indexPath.row < [[cameraKeys objectAtIndex:indexPath.section] count])) {
        [locationLabel setText:[[cameraKeys objectAtIndex:indexPath.section] objectAtIndex:row]];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self nameOfSection:section];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cameraName = [(UILabel*)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:89] text];
    NSString* locationName = [self nameOfSection:indexPath.section];
    
    if (![self shouldShowISOCameraView:locationName :cameraName]) {
        Camera* camera = [cameraModel cameraForLocation:locationName camera:cameraName];
        SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[camera url]];
        svc.delegate = self;
        [self presentViewController:svc animated:YES completion:nil];
    }
    
    // Deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)nameOfSection:(NSInteger)section {
    return locationKeys[section];
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSString* cameraName = [(UILabel*)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:89] text];
    NSString* locationName = [self nameOfSection:indexPath.section];
    
    return [self shouldShowISOCameraView:locationName :cameraName];
}

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

#pragma mark - SafariViewController delegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:true completion:nil];
}

@end
