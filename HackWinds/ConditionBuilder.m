//
//  ConditionBuilder.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import "ConditionBuilder.h"
#import "Condition.h"


@implementation ConditionBuilder

+ (NSArray*)conditionFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *conditions = [[NSMutableArray alloc] init];
    
    NSArray *results = [parsedObject valueForKey:@"results"];
    NSLog(@"Count %d", results.count);
    
    for (NSDictionary *conditionDic in results) {
        Condition *condition = [[Condition alloc] init];
        
        for (NSString *key in conditionDic) {
            if ([condition respondsToSelector:NSSelectorFromString(key)]) {
                [condition setValue:[conditionDic valueForKey:key] forKey:key];
            }
        }
        
        [conditions addObject:condition];
    }
    
    return conditions;
}

@end
