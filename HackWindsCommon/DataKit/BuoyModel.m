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
NSString * const TEXAS_TOWER_LOCATION = @"Texas Tower";
NSString * const BUOY_DATA_UPDATED_TAG = @"BuoyModelDidUpdateDataNotification";
NSString * const BUOY_LOCATION_CHANGED_TAG = @"BuoyLocationChangedNotification";
NSString * const DEFAULT_BUOY_LOCATION_CHANGED_TAG = @"DefaultBuoyLocationChangedNotification";
NSString * const BUOY_UPDATE_FAILED_TAG = @"BuoyModelUpdatedFailedNotification";

// URLs
static NSString * const BI_BUOY_ID = @"44097";
static NSString * const MTK_BUOY_ID = @"44017";
static NSString * const ACK_BUOY_ID = @"44008";
static NSString * const TT_BUOY_ID = @"44066";
static NSString * const NEWPORT_BUOY_ID = @"nwpr1";

@interface BuoyModel ()

// Private methods
- (void) initBuoyContainers;
- (void) fetchRawBuoyDataFromURL:(NSURL*)url withCompletionHandler:(void(^)(NSData*))completionHandler;
- (Buoy*) parseBuoyData:(NSData*)rawBuoyData;
- (double) getFootConvertedFromMetric:(double)metricValue;

// Private members
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSMutableDictionary *buoyDataContainers;

@end

@implementation BuoyModel
{
    BuoyDataContainer *currentContainer;
    BOOL fetching;
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
    
    fetching = NO;
    
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
    
    // Texas Tower
    BuoyDataContainer *texasTowerContainer = [[BuoyDataContainer alloc] init];
    texasTowerContainer.buoyID = TT_BUOY_ID;
    [self.buoyDataContainers setValue:texasTowerContainer forKey:TEXAS_TOWER_LOCATION];
}

- (void) resetData {
    [currentContainer resetData];
}

- (NSArray*) getBuoyLocations {
    return self.buoyDataContainers.allKeys;
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
    
    if (currentContainer.fetchTimestamp == nil) {
        return;
    }
    
    NSTimeInterval rawFetchTimeDiff = [[NSDate date] timeIntervalSinceDate:currentContainer.buoyData.timestamp];
    NSInteger fetchMinuteDiff = rawFetchTimeDiff / 60;
    
    if (fetchMinuteDiff > currentContainer.updateInterval) {
        [self resetData];
    }
}

- (BOOL) isFetching {
    return fetching;
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

- (void) refreshBuoyData {
    [self resetData];
    [self fetchBuoyData];
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
        
        fetching = YES;
        
        [self fetchRawBuoyDataFromURL:[currentContainer getLatestWaveDataURL] withCompletionHandler:^(NSData *data) {
            Buoy* buoyData = [self parseBuoyData:data];
            
            fetching = NO;
            
            if (buoyData != nil) {
                currentContainer.buoyData = buoyData;
                currentContainer.fetchTimestamp = [NSDate date];
                
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
        
        fetching = YES;
        
        [self fetchRawBuoyDataFromURL:[currentContainer getLatestSummaryURL] withCompletionHandler:^(NSData *data) {
            Buoy *buoyData = [self parseBuoyData:data];
            
            fetching = NO;
            
            if (buoyData != nil) {
                currentContainer.buoyData = buoyData;
                currentContainer.fetchTimestamp = [NSDate date];
                
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
    @synchronized (self) {
    
        [self fetchRawBuoyDataFromURL:[[self.buoyDataContainers objectForKey:location] getLatestSummaryURL] withCompletionHandler:^(NSData *rawData) {
            Buoy* buoyData = [self parseBuoyData:rawData];
        
            // Pass the buoy down to the completion handler
            if (buoyData != nil) {
                completionHandler(buoyData);
            }
        }];
    }
}

- (Buoy*) parseBuoyData:(NSData*)rawBuoyData {
    // Parse the data
    NSError *error;
    NSDictionary *rawData = [NSJSONSerialization
                             JSONObjectWithData:rawBuoyData
                             options:kNilOptions
                             error:&error];
    
    // If there's no data, return nothing
    if (rawData == nil) {
        return nil;
    } else if (error != nil) {
        return nil;
    }
    
    // Get the raw buoy data json object
    NSDictionary *buoyDataDict = [rawData objectForKey:@"BuoyData"];
    if (buoyDataDict == nil) {
        return nil;
    }
    
    // Create a fresh buoy data object
    Buoy *buoy = [[Buoy alloc] init];
    
    // Get and save the timestamp from the buoyreading
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    buoy.timestamp = [dateFormatter dateFromString:[buoyDataDict objectForKey:@"Date"]];
    
    // Get the wave summary
    Swell *waveSummary = [[Swell alloc] init];
    NSString *units = [[buoyDataDict objectForKey:@"WaveSummary"] objectForKey:@"Units"];
    waveSummary.waveHeight = [[buoyDataDict objectForKey:@"WaveSummary"] objectForKey:@"WaveHeight"];
    if ([units isEqualToString:@"metric"]) {
        waveSummary.waveHeight = [NSNumber numberWithDouble:[self getFootConvertedFromMetric:waveSummary.waveHeight.doubleValue]];
    }
    waveSummary.period = [[buoyDataDict objectForKey:@"WaveSummary"] objectForKey:@"Period"];
    waveSummary.direction = [[buoyDataDict objectForKey:@"WaveSummary"] objectForKey:@"Direction"];
    waveSummary.compassDirection = [[buoyDataDict objectForKey:@"WaveSummary"] objectForKey:@"CompassDirection"];
    buoy.waveSummary = waveSummary;
    
    // Get the swell components
    NSMutableArray *swellComponents = [[NSMutableArray alloc] init];
    NSArray *rawComponents = [buoyDataDict objectForKey:@"SwellComponents"];
    for (NSDictionary* swellDict in rawComponents) {
        Swell *swellComponent = [[Swell alloc] init];
        swellComponent.waveHeight = [swellDict objectForKey:@"WaveHeight"];
        if ([units isEqualToString:@"metric"]) {
            swellComponent.waveHeight = [NSNumber numberWithDouble:[self getFootConvertedFromMetric:swellComponent.waveHeight.doubleValue]];
        }
        swellComponent.period = [swellDict objectForKey:@"Period"];
        swellComponent.direction = [swellDict objectForKey:@"Direction"];
        swellComponent.compassDirection = [swellDict objectForKey:@"CompassDirection"];
        
        [swellComponents addObject:swellComponent];
    }
    buoy.swellComponents = swellComponents;
    
    // Get the water temperature
    buoy.waterTemperature = [NSNumber numberWithDouble: [self getFahrenheitConvertedFromCelsius:[[buoyDataDict objectForKey:@"WaterTemperature"] doubleValue]]];
    
    // Get the raw charts
    buoy.directionalWaveSpectraPlotURL = [rawData objectForKey:@"DirectionalSpectraPlot"];
    buoy.waveEnergySpectraPlotURL = [rawData objectForKey:@"SpectraDistributionPlot"];

    return buoy;
}

- (double) getFootConvertedFromMetric:(double)metricValue {
    return metricValue * 3.28;
}

- (double) getFahrenheitConvertedFromCelsius:(double)celsiusValue {
    return (celsiusValue * 1.8) + 32.0;
}

@end
