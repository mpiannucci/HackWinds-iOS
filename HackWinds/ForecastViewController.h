//
//  ForecastViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForecastViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (void)fetchedMSWData:(NSData *)responseData;
- (NSString *)formatDate:(NSUInteger)epoch;
- (Boolean)checkDate:(NSString *)dateString;


@end
