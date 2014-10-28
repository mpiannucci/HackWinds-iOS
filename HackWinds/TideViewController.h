//
//  ThirdViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TideViewController : UIViewController

- (void)fetchedTideData:(NSData *)responseData;

- (void)reloadView;

@end
