//
//  DetailedForecastViewController.h
//  HackWinds
//
//  Created by Matthew Iannucci on 3/30/15.
//  Copyright (c) 2015 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailedForecastViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property NSInteger dayIndex;

-(void) getModelData;

@end
