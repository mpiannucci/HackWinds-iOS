//
//  SwitchableChartView.h
//  HackWinds
//
//  Created by Matthew Iannucci on 11/6/17.
//  Copyright © 2017 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchableChartView : UIView

@property NSInteger conditonCount;
@property NSInteger dayIndex;

- (id) initWithDayIndex:(NSInteger)index conditionCount:(NSInteger)count;

- (void) initialize;
- (void) cleanup;

@end
