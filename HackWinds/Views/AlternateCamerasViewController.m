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
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load locations from file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CameraLocations"
                                                     ofType:@"plist"];
    cameraURLs = [NSDictionary dictionaryWithContentsOfFile:path];
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
    switch (section) {
        case 0:
            return [[cameraURLs objectForKey:@"Narragansett"] count] - 2;
        case 1:
            return [[cameraURLs objectForKey:@"Newport"] count];
        case 2:
            return [[cameraURLs objectForKey:@"Hull"] count];
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cameraLocationItem" forIndexPath:indexPath];
    
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:89];
    
    switch (indexPath.section) {
        case 0:
            // Always the juice cam
            [locationLabel setText:@"Town Beach South"];
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [locationLabel setText:@"Easton Beach West"];
                    break;
                case 1:
                    [locationLabel setText:@"Easton Beach East"];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [locationLabel setText:@"Nantasket North"];
                    break;
                case 1:
                    [locationLabel setText:@"Nantasket South"];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self nameOfSection:section];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect the row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)nameOfSection:(NSInteger)section {
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Narragansett";
            break;
        case 1:
            sectionName = @"Newport";
            break;
        case 2:
            sectionName = @"Hull";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
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
