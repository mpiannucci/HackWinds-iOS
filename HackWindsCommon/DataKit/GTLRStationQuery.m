// NOTE: This file was generated by the ServiceGenerator.

// ----------------------------------------------------------------------------
// API:
//   station/v1
// Description:
//   This is an API

#import "GTLRStationQuery.h"

#import "GTLRStationObjects.h"

// ----------------------------------------------------------------------------
// Constants

// buoyType
NSString * const kGTLRStationBuoyTypeBuoy   = @"BUOY";
NSString * const kGTLRStationBuoyTypeDart   = @"DART";
NSString * const kGTLRStationBuoyTypeFixed  = @"FIXED";
NSString * const kGTLRStationBuoyTypeNone   = @"NONE";
NSString * const kGTLRStationBuoyTypeOilrig = @"OILRIG";
NSString * const kGTLRStationBuoyTypeOther  = @"OTHER";
NSString * const kGTLRStationBuoyTypeTao    = @"TAO";

// dataType
NSString * const kGTLRStationDataTypeSpectra = @"SPECTRA";
NSString * const kGTLRStationDataTypeWaves   = @"WAVES";
NSString * const kGTLRStationDataTypeWeather = @"WEATHER";

// plotType
NSString * const kGTLRStationPlotTypeDirection = @"DIRECTION";
NSString * const kGTLRStationPlotTypeEnergy    = @"ENERGY";

// units
NSString * const kGTLRStationUnitsEnglish = @"ENGLISH";
NSString * const kGTLRStationUnitsMetric  = @"METRIC";

// ----------------------------------------------------------------------------
// Query Classes
//

@implementation GTLRStationQuery

@dynamic fields;

@end

@implementation GTLRStationQuery_ClosestStation

@dynamic active, buoyType, count, latitude, longitude;

+ (NSDictionary<NSString *, NSString *> *)parameterNameMap {
  return @{ @"buoyType" : @"buoy_type" };
}

+ (instancetype)queryWithActive:(BOOL)active
                          count:(long long)count
                       latitude:(double)latitude
                      longitude:(double)longitude
                       buoyType:(NSString *)buoyType {
  NSString *pathURITemplate = @"stations/closest";
  GTLRStationQuery_ClosestStation *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:nil
                       pathParameterNames:nil];
  query.active = active;
  query.count = count;
  query.latitude = latitude;
  query.longitude = longitude;
  query.buoyType = buoyType;
  query.expectedObjectClass = [GTLRStation_ApiApiMessagesStationMessage class];
  query.loggingName = @"station.closest_station";
  return query;
}

@end

@implementation GTLRStationQuery_Data

@dynamic dataType, stationId, units, whenMilliseconds, whenTimeZoneOffset;

+ (NSDictionary<NSString *, NSString *> *)parameterNameMap {
  NSDictionary<NSString *, NSString *> *map = @{
    @"dataType" : @"data_type",
    @"stationId" : @"station_id",
    @"whenMilliseconds" : @"when.milliseconds",
    @"whenTimeZoneOffset" : @"when.time_zone_offset"
  };
  return map;
}

+ (instancetype)queryWithUnits:(NSString *)units
                     stationId:(NSString *)stationId {
  NSString *pathURITemplate = @"data";
  GTLRStationQuery_Data *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:nil
                       pathParameterNames:nil];
  query.units = units;
  query.stationId = stationId;
  query.expectedObjectClass = [GTLRStation_ApiApiMessagesDataMessage class];
  query.loggingName = @"station.data";
  return query;
}

@end

@implementation GTLRStationQuery_Info

@dynamic stationId;

+ (NSDictionary<NSString *, NSString *> *)parameterNameMap {
  return @{ @"stationId" : @"station_id" };
}

+ (instancetype)queryWithStationId:(NSString *)stationId {
  NSString *pathURITemplate = @"info";
  GTLRStationQuery_Info *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:nil
                       pathParameterNames:nil];
  query.stationId = stationId;
  query.expectedObjectClass = [GTLRStation_ApiApiMessagesStationMessage class];
  query.loggingName = @"station.info";
  return query;
}

@end

@implementation GTLRStationQuery_Plot

@dynamic plotType, stationId;

+ (NSDictionary<NSString *, NSString *> *)parameterNameMap {
  NSDictionary<NSString *, NSString *> *map = @{
    @"plotType" : @"plot_type",
    @"stationId" : @"station_id"
  };
  return map;
}

+ (instancetype)queryWithPlotType:(NSString *)plotType
                        stationId:(NSString *)stationId {
  NSString *pathURITemplate = @"plot";
  GTLRStationQuery_Plot *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:nil
                       pathParameterNames:nil];
  query.plotType = plotType;
  query.stationId = stationId;
  query.expectedObjectClass = [GTLRStation_ApiApiMessagesPlotMessage class];
  query.loggingName = @"station.plot";
  return query;
}

@end

@implementation GTLRStationQuery_Stations

+ (instancetype)query {
  NSString *pathURITemplate = @"stations";
  GTLRStationQuery_Stations *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:nil
                       pathParameterNames:nil];
  query.expectedObjectClass = [GTLRStation_ApiApiMessagesStationsMessage class];
  query.loggingName = @"station.stations";
  return query;
}

@end

@implementation GTLRStationQuery_UnitLabels

@dynamic abbrev, units;

+ (instancetype)queryWithUnits:(NSString *)units
                        abbrev:(BOOL)abbrev {
  NSString *pathURITemplate = @"unit_labels";
  GTLRStationQuery_UnitLabels *query =
    [[self alloc] initWithPathURITemplate:pathURITemplate
                               HTTPMethod:nil
                       pathParameterNames:nil];
  query.units = units;
  query.abbrev = abbrev;
  query.expectedObjectClass = [GTLRStation_ApiApiMessagesUnitLabelMessage class];
  query.loggingName = @"station.unit_labels";
  return query;
}

@end