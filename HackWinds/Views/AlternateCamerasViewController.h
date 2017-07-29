//
//  AlternateCamerasViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 5/4/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>


@interface AlternateCamerasViewController : UITableViewController <SFSafariViewControllerDelegate>

- (NSString *)nameOfSection:(NSInteger)section;
- (IBAction)closeViewClicked:(id)sender;

@end
