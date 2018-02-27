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
NSString * const LONG_ISLAND_LOCATION = @"Long Island";
NSString * const NEWPORT_LOCATION = @"Newport";
NSString * const TEXAS_TOWER_LOCATION = @"Texas Tower";
NSString * const BUOY_DATA_UPDATED_TAG = @"BuoyModelDidUpdateDataNotification";
NSString * const BUOY_LOCATION_CHANGED_TAG = @"BuoyLocationChangedNotification";
NSString * const DEFAULT_BUOY_LOCATION_CHANGED_TAG = @"DefaultBuoyLocationChangedNotification";
NSString * const BUOY_UPDATE_FAILED_TAG = @"BuoyModelUpdatedFailedNotification";

// URLs
static NSString * const BI_BUOY_ID = @"44097";
static NSString * const MTK_BUOY_ID = @"44017";
static NSString * const LI_BUOY_ID = @"44025";
static NSString * const ACK_BUOY_ID = @"44008";
static NSString * const TT_BUOY_ID = @"44066";
static NSString * const NEWPORT_BUOY_ID = @"nwpr1";

// Keys
static NSString * const BUOYFINDER_KEY = @"AIzaSyBbIPovaMqVVvXvFzoIbW7ul48UJ6p7Npg";

@interface BuoyModel ()

// Private methods
- (void) initBuoyContainers;
- (void) fetchBuoyQuery:(GTLRStationQuery*)query withCompletionHandler:(void(^)(GTLRObject*))completionHandler;
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
                                             selector:@selector(changeBuoyLocationAndUpdate)
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
    
    // Long Island
    BuoyDataContainer *liContainer = [[BuoyDataContainer alloc] init];
    liContainer.buoyID = LI_BUOY_ID;
    [self.buoyDataContainers setValue:liContainer forKey:LONG_ISLAND_LOCATION];
    
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

- (GTLRStation_ApiApiMessagesDataMessage *) getBuoyData {
    return currentContainer.buoyData;
}

- (void) changeBuoyLocation {
    [self.defaults synchronize];
    
    // Get the correct container and send out the notification for everything to update
    currentContainer = [self.buoyDataContainers objectForKey:[self.defaults objectForKey:@"BuoyLocation"]];
}

- (void) changeBuoyLocationAndUpdate {
    [self changeBuoyLocation];
    
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
    
    NSTimeInterval rawFetchTimeDiff = [[NSDate date] timeIntervalSinceDate:currentContainer.buoyData.date.date];
    NSInteger fetchMinuteDiff = rawFetchTimeDiff / 60;
    
    if (fetchMinuteDiff > currentContainer.updateInterval) {
        [self resetData];
    }
}

- (BOOL) isFetching {
    return fetching;
}

- (void) fetchBuoyQuery:(GTLRStationQuery *)query withCompletionHandler:(void(^)(GTLRObject*))completionHandler {
    
    GTLRStationService *service = [[GTLRStationService alloc] init];
    service.APIKey = BUOYFINDER_KEY;
    [service executeQuery:query completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        // TODO: Parse data out
        if (callbackError != nil) {
            NSLog(@"BuoyFinder Error: %@", callbackError);
            completionHandler(nil);
        } else if (object == nil) {
            completionHandler(nil);
        }
        
        if (![object isKindOfClass:[GTLRObject class]]) {
            completionHandler(nil);
        }
        
        completionHandler((GTLRObject*)object);
    }];
}

- (void) refreshBuoyData {
    [self resetData];
    [self fetchBuoyData];
}

- (void) fetchBuoyActive:(void(^)(bool))completionHandler; {
    @synchronized(self) {
        fetching = YES;
        
        GTLRStationQuery_Info *infoQuery = [GTLRStationQuery_Info queryWithStationId:currentContainer.buoyID];
        [self fetchBuoyQuery:infoQuery withCompletionHandler:^(GTLRObject *object) {
            BOOL active = NO;
            if (object == nil) {
                active = NO;
            } else if ([object isKindOfClass:[GTLRStation_ApiApiMessagesStationMessage class]]) {
                active = [((GTLRStation_ApiApiMessagesStationMessage*) object).active boolValue];
            }
            
            currentContainer.active = active;
            fetching = NO;
            if (completionHandler != nil) {
                completionHandler(currentContainer.active);
            }
        }];
    }
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
        
        GTLRStationQuery_Data *dataQuery = [GTLRStationQuery_Data queryWithUnits:kGTLRStationUnitsEnglish stationId:currentContainer.buoyID];
        dataQuery.dataType = kGTLRStationDataTypeSpectra;
        
        [self fetchBuoyQuery:dataQuery withCompletionHandler:^(GTLRObject *object) {
            fetching = NO;
            if (object == nil) {
                // Do nothing for now
                return;
            }
            
            if ([object isKindOfClass:[GTLRStation_ApiApiMessagesDataMessage class]]) {
                currentContainer.buoyData = (GTLRStation_ApiApiMessagesDataMessage*)object;
                currentContainer.fetchTimestamp = [NSDate date];
            }
            
            if (currentContainer.buoyData != nil) {
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
        
        GTLRStationQuery_Data *dataQuery = [GTLRStationQuery_Data queryWithUnits:kGTLRStationUnitsEnglish stationId:currentContainer.buoyID];
        [self fetchBuoyQuery:dataQuery withCompletionHandler:^(GTLRObject *object) {
            fetching = NO;
            
            if ([object isKindOfClass:[GTLRStation_ApiApiMessagesDataMessage class]]) {
                currentContainer.buoyData = (GTLRStation_ApiApiMessagesDataMessage*)object;
                currentContainer.fetchTimestamp = [NSDate date];
            }
            
            if (currentContainer.buoyData != nil) {
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

- (void) fetchLatestBuoyDataForLocation:(NSString *)location withCompletionHandler:(void (^)(GTLRStation_ApiApiMessagesDataMessage *))completionHandler {
    @synchronized (self) {
        
        BuoyDataContainer *dataContainer = [self.buoyDataContainers objectForKey:location];
        GTLRStationQuery_Data *dataQuery = [GTLRStationQuery_Data queryWithUnits:kGTLRStationUnitsEnglish stationId: dataContainer.buoyID];
        [self fetchBuoyQuery:dataQuery withCompletionHandler:^(GTLRObject *object) {
            GTLRStation_ApiApiMessagesDataMessage *data = nil;
            if (object == nil) {
                data = nil;
            } else if ([object isKindOfClass:[GTLRStation_ApiApiMessagesDataMessage class]]) {
                data = (GTLRStation_ApiApiMessagesDataMessage*)object;
            }
            
            if (completionHandler != nil) {
                completionHandler(data);
            }
        }];
    }
}

- (NSMutableURLRequest*) fetchLatestBuoyDataRequestForLocation:(NSString*)location {
    BuoyDataContainer *dataContainer = [self.buoyDataContainers objectForKey:location];
    GTLRStationQuery_Data *dataQuery = [GTLRStationQuery_Data queryWithUnits:kGTLRStationUnitsEnglish stationId: dataContainer.buoyID];
    GTLRStationService *service = [[GTLRStationService alloc] init];
    service.APIKey = BUOYFINDER_KEY;
    return [service requestForQuery:dataQuery];
}

+ (GTLRStation_ApiApiMessagesDataMessage*) buoyDataFromRawData:(NSData*)data {
    if (data == nil) {
        return nil;
    }
    
    NSMutableDictionary *dict =
    [NSPropertyListSerialization propertyListWithData:data
                                              options:NSPropertyListMutableContainers
                                               format:nil
                                                error:nil];
    
    if (dict == nil) {
        return nil;
    }
    
    GTLRStationService *service = [[GTLRStationService alloc] init];
    service.APIKey = BUOYFINDER_KEY;
    GTLRStation_ApiApiMessagesDataMessage *buoyData =
    [GTLRStation_ApiApiMessagesDataMessage objectWithJSON:dict
                    objectClassResolver:service.objectClassResolver];
    return buoyData;
}

- (double) getFootConvertedFromMetric:(double)metricValue {
    return metricValue * 3.28;
}

- (double) getFahrenheitConvertedFromCelsius:(double)celsiusValue {
    return (celsiusValue * 1.8) + 32.0;
}

@end
