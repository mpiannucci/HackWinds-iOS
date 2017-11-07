//
//  SwitchableChartView.h
//  HackWinds
//
//  Created by Matthew Iannucci on 11/6/17.
//  Copyright © 2017 Rhodysurf Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchableChartView : UIView

- (id) initWithDayIndex:(NSInteger)index conditionCount:(NSInteger)count;

- (void) initialize;
- (void) cleanup;

- (void) setConditionCount:(NSInteger)count;
- (void) setDayIndex:(NSInteger)index;

@end
