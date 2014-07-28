//
//  ConditionCommunicator.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/27/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import "ConditionCommunicator.h"
#import "ConditionDelegate.h"

@implementation ConditionCommunicator

-(void)getConditionData:(int)numData forOffset:(int)offset
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://magicseaweed.com/api/nFSL2f845QOAf1Tuv7Pf5Pd9PXa5sVTS/forecast/?spot_id=1103&fields=localTimestamp,swell.*,wind.*"];
    NSURL *mswURl = [[NSURL alloc] initWithString:urlAsString];
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:mswURl] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.delegate fetchingConditionFailedWithError:error];
        } else {
            [self.delegate receivedConditionJSON:data];
        }
    }];
}

@end
