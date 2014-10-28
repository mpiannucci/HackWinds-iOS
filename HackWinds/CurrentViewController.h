//
//  FirstViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (NSString *)getDayHeader:(NSDate *)date;
- (void)fetchedMSWData:(NSData *)responseData;
- (NSString *)formatDate:(NSUInteger)epoch;
- (Boolean)checkDate:(NSString *)dateString;

- (IBAction)playButton:(id)sender;

@end
