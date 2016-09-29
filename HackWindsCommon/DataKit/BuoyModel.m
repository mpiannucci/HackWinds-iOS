//
//  BuoyModel.m
//  HackWinds
//
//  Created by Matthew Iannucci on 12/14/14.
//  Copyright (c) 2014 Rhodysurf Development. All rights reserved.
//

#import "BuoyModel.h"
#import "BuoyDataContainer.h"
#import "XMLReader.h"

// Global Constants
NSString * const BLOCK_ISLAND_LOCATION = @"Block Island";
NSString * const MONTAUK_LOCATION = @"Montauk";
NSString * const NANTUCKET_LOCATION =  @"Nantucket";
NSString * const NEWPORT_LOCATION = @"Newport";
NSString * const SUMMARY_DATA_MODE = @"Summary";
NSString * const SWELL_DATA_MODE = @"Swell";
NSString * const WIND_DATA_MODE = @"Wind Wave";
NSString * const BUOY_DATA_UPDATED_TAG = @"BuoyModelDidUpdateDataNotification";
NSString * const BUOY_LOCATION_CHANGED_TAG = @"BuoyLocationChangedNotification";
NSString * const DEFAULT_BUOY_LOCATION_CHANGED_TAG = @"DefaultBuoyLocationChangedNotification";
NSString * const BUOY_UPDATE_FAILED_TAG = @"BuoyModelUpdatedFailedNotification";

// URLs
static NSString * const BI_BUOY_ID = @"44097";
static NSString * const MTK_BUOY_ID = @"44017";
static NSString * const ACK_BUOY_ID = @"44008";
static NSString * const NEWPORT_BUOY_ID = @"nwpr1";

@interface BuoyModel ()

// Private methods
- (void) initBuoyContainers;
- (void) fetchRawBuoyDataFromURL:(NSURL*)url withCompletionHandler:(void(^)(NSData*))completionHandler;
- (BOOL) parseBuoyData:(NSData*)rawBuoyData;
- (double) getFootConvertedFromMetric:(double)metricValue;

// Private members
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSMutableDictionary *buoyDataContainers;

@end

@implementation BuoyModel
{
    int timeOffset;
    BuoyDataContainer *currentContainer;
}

+ (instancetype) sharedModel {
    static BuoyModel *_sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be executed once - thread safe version!
        _sharedModel = [[self alloc] init];
    });
    
    return _sharedModel;
}

- (id)init {
    self = [super init];
    
    [self initBuoyContainers];
    
    // Check if daylight savings is in effect. Make sure the time scaling is for EST (GMT-5)
    NSTimeZone* eastnTZ = [NSTimeZone timeZoneWithName:@"EST5EDT"];
    int daylightoff = [eastnTZ daylightSavingTimeOffset]/3600;
    timeOffset = -5 + daylightoff;
    
    // Grab the latest user defaults
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [self.defaults synchronize];
    
    // Register to listen for the location being changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeBuoyLocation)
                                                 name:BUOY_LOCATION_CHANGED_TAG
                                               object:nil];
    
    // Initilize the location state
    [self changeBuoyLocation];
    
    return self;
}

- (void) initBuoyContainers {
    self.buoyDataContainers = [[NSMutableDictionary alloc] init];
    
    // Block Island
    BuoyDataContainer *biContainer = [[BuoyDataContainer alloc] init];
    biContainer.buoyID = BI_BUOY_ID;
    [self.buoyDataContainers setValue:biContainer forKey:BLOCK_ISLAND_LOCATION];
    
    // Montauk
    BuoyDataContainer *mtkContainer = [[BuoyDataContainer alloc] init];
    mtkContainer.buoyID = MTK_BUOY_ID;
    [self.buoyDataContainers setValue:mtkContainer forKey:MONTAUK_LOCATION];
    
    // Nantucket
    BuoyDataContainer *ackContainer = [[BuoyDataContainer alloc] init];
    ackContainer.buoyID = ACK_BUOY_ID;
    [self.buoyDataContainers setValue:ackContainer forKey:NANTUCKET_LOCATION];
    
    // Newport
    BuoyDataContainer *newportContainer = [[BuoyDataContainer alloc] init];
    newportContainer.buoyID = NEWPORT_BUOY_ID;
    [self.buoyDataContainers setValue:newportContainer forKey:NEWPORT_LOCATION];
}

- (int) getTimeOffset {
    return timeOffset;
}

- (void) resetData {
    [currentContainer resetData];
}

- (Buoy *) getBuoyData {
    return currentContainer.buoyData;
}

- (void) changeBuoyLocation {
    [self.defaults synchronize];
    
    // Get the correct container and send out the notification for everything to update
    currentContainer = [self.buoyDataContainers objectForKey:[self.defaults objectForKey:@"BuoyLocation"]];
    
    [self fetchBuoyData];
}

- (void) forceChangeLocation:(NSString *)location {
    // Get the correct container and send out the notification for everything to update
    currentContainer = [self.buoyDataContainers objectForKey:location];
    
    // NOTE: For the force we dont automatically refetch
}

- (void) checkForUpdate {
    if (currentContainer.buoyData == nil) {
        return;
    }
    
    if (currentContainer.buoyData.timestamp == nil) {
        return;
    }
    
    NSTimeInterval rawTimeDiff = [[NSDate date] timeIntervalSinceDate:currentContainer.buoyData.timestamp];
    NSInteger minuteDiff = rawTimeDiff / 60;
    
    if (minuteDiff > currentContainer.updateInterval) {
        [self resetData];
    }
}

- (void) fetchRawBuoyDataFromURL:(NSURL*)url withCompletionHandler:(void(^)(NSData*))completionHandler {
    NSURLSessionTask *buoyTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Failed to retreive tide data from API");
            
            // Send failure notification
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:BUOY_UPDATE_FAILED_TAG
                 object:self];
            });
            
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode != 200) {
            NSLog(@"HTTP Error receiving buoy data");
            
            // Send failure notification
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:BUOY_UPDATE_FAILED_TAG
                 object:self];
            });
            
            return;
        }
        
        completionHandler(data);
    }];
    
    [buoyTask resume];
}

- (void) fetchBuoyData {
    @synchronized(self) {
        [self checkForUpdate];
        
        if (currentContainer.buoyData != nil) {
            // Tell everything you have buoy data
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:BUOY_DATA_UPDATED_TAG
                 object:self];
            });
            return;
        }
        
        [self fetchRawBuoyDataFromURL:[currentContainer getLatestWaveDataURL] withCompletionHandler:^(NSData *data) {
            BOOL parsedBuoys = [self parseBuoyData:data];
            
            if (parsedBuoys) {
                // Tell everything you have buoy data
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:BUOY_DATA_UPDATED_TAG
                     object:self];
                });
            }
        }];
        
    }
}

- (void) fetchLatestSummaryData {
    @synchronized(self) {
        [self checkForUpdate];
        
        if (currentContainer.buoyData != nil) {
            // Tell everything you have buoy data
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:BUOY_DATA_UPDATED_TAG
                 object:self];
            });
            return;
        }
        
        [self fetchRawBuoyDataFromURL:[currentContainer getLatestSummaryURL] withCompletionHandler:^(NSData *data) {
            BOOL parsedBuoys = [self parseBuoyData:data];
            
            if (parsedBuoys) {
                // Tell everything you have buoy data
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:BUOY_DATA_UPDATED_TAG
                     object:self];
                });
            }
        }];
        
    }
}

- (void) fetchLatestBuoyDataForLocation:(NSString *)location withCompletionHandler:(void (^)(Buoy *))completionHandler {
    NSString *originalLocation = [self.defaults objectForKey:@"BuoyLocation"];
    [self forceChangeLocation:location];
    
    [self fetchRawBuoyDataFromURL:[currentContainer getLatestSummaryURL] withCompletionHandler:^(NSData *rawData) {
        BOOL parsed = [self parseBuoyData:rawData];
        
        // Pass the buoy down to the completion handler
        if (parsed) {
         completionHandler(currentContainer.buoyData);
        }
    }];
    
    [self forceChangeLocation:originalLocation];
}

- (BOOL) parseBuoyData:(NSData*)rawBuoyData {
    // Parse the data
    NSError *error;
    NSDictionary *rawData = [NSJSONSerialization
                             JSONObjectWithData:rawBuoyData
                             options:kNilOptions
                             error:&error];
    
    // If there's no data, return nothing
    if (rawData == nil) {
        return NO;
    } else if (error != nil) {
        return NO;
    }
    
    // Get the raw buoy data json object
    NSDictionary *buoyDataDict = [rawData objectForKey:@"BuoyData"];
    if (buoyDataDict == nil) {
        return NO;
    }
    
    // Create a fresh buoy data object
    Buoy *buoy = [[Buoy alloc] init];
    
    // Get and save the timestamp from the buoyreading
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE MMMM dd, yyyy HHZ"];
    buoy.timestamp = [dateFormatter dateFromString:[buoyDataDict objectForKey:@"Date"]];
    
    // Get the wave summary
    Swell *waveSummary = [[Swell alloc] init];
    
    // Get the swell components
    
    // Get the water temperature
    
    // Get the raw charts
    
    return NO;
}

- (double) getFootConvertedFromMetric:(double)metricValue {
    return metricValue * 3.28;
}

@end
