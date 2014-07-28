//
//  ConditionBuilder.h
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConditionBuilder : NSObject

+ (NSArray*)conditionFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
