// NOTE: This file was generated by the ServiceGenerator.

// ----------------------------------------------------------------------------
// API:
//   hackwinds/v1
// Description:
//   This is an API

#import "GTLRHackwindsObjects.h"

// ----------------------------------------------------------------------------
// Constants

// GTLRHackwinds_ModelCameraMessagesCameraMessage.refreshMethod
NSString * const kGTLRHackwinds_ModelCameraMessagesCameraMessage_RefreshMethod_None = @"NONE";
NSString * const kGTLRHackwinds_ModelCameraMessagesCameraMessage_RefreshMethod_Sequential = @"SEQUENTIAL";
NSString * const kGTLRHackwinds_ModelCameraMessagesCameraMessage_RefreshMethod_Static = @"STATIC";

// GTLRHackwinds_ModelForecastMessagesMeasurementLabelMessage.measurement
NSString * const kGTLRHackwinds_ModelForecastMessagesMeasurementLabelMessage_Measurement_Direction = @"DIRECTION";
NSString * const kGTLRHackwinds_ModelForecastMessagesMeasurementLabelMessage_Measurement_Length = @"LENGTH";
NSString * const kGTLRHackwinds_ModelForecastMessagesMeasurementLabelMessage_Measurement_Pressure = @"PRESSURE";
NSString * const kGTLRHackwinds_ModelForecastMessagesMeasurementLabelMessage_Measurement_Speed = @"SPEED";
NSString * const kGTLRHackwinds_ModelForecastMessagesMeasurementLabelMessage_Measurement_Temperature = @"TEMPERATURE";
NSString * const kGTLRHackwinds_ModelForecastMessagesMeasurementLabelMessage_Measurement_Visibility = @"VISIBILITY";

// GTLRHackwinds_ModelForecastMessagesSurfForecastSummaryMessage.conditions
NSString * const kGTLRHackwinds_ModelForecastMessagesSurfForecastSummaryMessage_Conditions_Decent = @"DECENT";
NSString * const kGTLRHackwinds_ModelForecastMessagesSurfForecastSummaryMessage_Conditions_Epic = @"EPIC";
NSString * const kGTLRHackwinds_ModelForecastMessagesSurfForecastSummaryMessage_Conditions_Flat = @"FLAT";
NSString * const kGTLRHackwinds_ModelForecastMessagesSurfForecastSummaryMessage_Conditions_Good = @"GOOD";
NSString * const kGTLRHackwinds_ModelForecastMessagesSurfForecastSummaryMessage_Conditions_Poor = @"POOR";

// GTLRHackwinds_ModelForecastMessagesUnitLabelMessage.unit
NSString * const kGTLRHackwinds_ModelForecastMessagesUnitLabelMessage_Unit_English = @"ENGLISH";
NSString * const kGTLRHackwinds_ModelForecastMessagesUnitLabelMessage_Unit_Metric = @"METRIC";

// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelCameraMessagesCameraLocationsMessage
//

@implementation GTLRHackwinds_ModelCameraMessagesCameraLocationsMessage
@dynamic cameraLocations;

+ (NSDictionary<NSString *, NSString *> *)propertyToJSONKeyMap {
  return @{ @"cameraLocations" : @"camera_locations" };
}

+ (NSDictionary<NSString *, Class> *)arrayPropertyToClassMap {
  NSDictionary<NSString *, Class> *map = @{
    @"camera_locations" : [GTLRHackwinds_ModelCameraMessagesCameraRegionMessage class]
  };
  return map;
}

@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelCameraMessagesCameraMessage
//

@implementation GTLRHackwinds_ModelCameraMessagesCameraMessage
@dynamic imageUrl, info, name, premium, refreshInterval, refreshMethod,
         refreshable, videoUrl, webUrl;

+ (NSDictionary<NSString *, NSString *> *)propertyToJSONKeyMap {
  NSDictionary<NSString *, NSString *> *map = @{
    @"imageUrl" : @"image_url",
    @"refreshInterval" : @"refresh_interval",
    @"refreshMethod" : @"refresh_method",
    @"videoUrl" : @"video_url",
    @"webUrl" : @"web_url"
  };
  return map;
}

@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelCameraMessagesCameraRegionMessage
//

@implementation GTLRHackwinds_ModelCameraMessagesCameraRegionMessage
@dynamic cameras, name;

+ (NSDictionary<NSString *, Class> *)arrayPropertyToClassMap {
  NSDictionary<NSString *, Class> *map = @{
    @"cameras" : [GTLRHackwinds_ModelCameraMessagesCameraMessage class]
  };
  return map;
}

@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelForecastMessagesDataMessage
//

@implementation GTLRHackwinds_ModelForecastMessagesDataMessage
@dynamic airTemperature, averagePeriod, date, dewpointTemperature,
         directionSpectraPlot, energySpectraPlot, maximumBreakingHeight,
         minimumBreakingHeight, pressure, pressureTendency, steepness,
         swellComponents, unit, waterLevel, waterTemperature, waveSpectra,
         waveSummary, windCompassDirection, windDirection, windGust, windSpeed;

+ (NSDictionary<NSString *, NSString *> *)propertyToJSONKeyMap {
  NSDictionary<NSString *, NSString *> *map = @{
    @"airTemperature" : @"air_temperature",
    @"averagePeriod" : @"average_period",
    @"dewpointTemperature" : @"dewpoint_temperature",
    @"directionSpectraPlot" : @"direction_spectra_plot",
    @"energySpectraPlot" : @"energy_spectra_plot",
    @"maximumBreakingHeight" : @"maximum_breaking_height",
    @"minimumBreakingHeight" : @"minimum_breaking_height",
    @"pressureTendency" : @"pressure_tendency",
    @"swellComponents" : @"swell_components",
    @"waterLevel" : @"water_level",
    @"waterTemperature" : @"water_temperature",
    @"waveSpectra" : @"wave_spectra",
    @"waveSummary" : @"wave_summary",
    @"windCompassDirection" : @"wind_compass_direction",
    @"windDirection" : @"wind_direction",
    @"windGust" : @"wind_gust",
    @"windSpeed" : @"wind_speed"
  };
  return map;
}

+ (NSDictionary<NSString *, Class> *)arrayPropertyToClassMap {
  NSDictionary<NSString *, Class> *map = @{
    @"swell_components" : [GTLRHackwinds_ModelForecastMessagesSwellMessage class]
  };
  return map;
}

@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelForecastMessagesLocationMessage
//

@implementation GTLRHackwinds_ModelForecastMessagesLocationMessage
@dynamic altitude, latitude, longitude, name;
@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelForecastMessagesMeasurementLabelMessage
//

@implementation GTLRHackwinds_ModelForecastMessagesMeasurementLabelMessage
@dynamic label, measurement;
@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelForecastMessagesNOAAModelMessage
//

@implementation GTLRHackwinds_ModelForecastMessagesNOAAModelMessage
@dynamic descriptionProperty, modelRun, name;

+ (NSDictionary<NSString *, NSString *> *)propertyToJSONKeyMap {
  NSDictionary<NSString *, NSString *> *map = @{
    @"descriptionProperty" : @"description",
    @"modelRun" : @"model_run"
  };
  return map;
}

@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelForecastMessagesSurfForecastDayMessage
//

@implementation GTLRHackwinds_ModelForecastMessagesSurfForecastDayMessage
@dynamic data, date, summary;

+ (NSDictionary<NSString *, Class> *)arrayPropertyToClassMap {
  NSDictionary<NSString *, Class> *map = @{
    @"data" : [GTLRHackwinds_ModelForecastMessagesDataMessage class],
    @"summary" : [GTLRHackwinds_ModelForecastMessagesSurfForecastSummaryMessage class]
  };
  return map;
}

@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelForecastMessagesSurfForecastMessage
//

@implementation GTLRHackwinds_ModelForecastMessagesSurfForecastMessage
@dynamic fetchDate, forecast, forecastLocation, swellLocation, waveModelInfo,
         weatherModelInfo, windLocation;

+ (NSDictionary<NSString *, NSString *> *)propertyToJSONKeyMap {
  NSDictionary<NSString *, NSString *> *map = @{
    @"fetchDate" : @"fetch_date",
    @"forecastLocation" : @"forecast_location",
    @"swellLocation" : @"swell_location",
    @"waveModelInfo" : @"wave_model_info",
    @"weatherModelInfo" : @"weather_model_info",
    @"windLocation" : @"wind_location"
  };
  return map;
}

+ (NSDictionary<NSString *, Class> *)arrayPropertyToClassMap {
  NSDictionary<NSString *, Class> *map = @{
    @"forecast" : [GTLRHackwinds_ModelForecastMessagesSurfForecastDayMessage class]
  };
  return map;
}

@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelForecastMessagesSurfForecastSummaryMessage
//

@implementation GTLRHackwinds_ModelForecastMessagesSurfForecastSummaryMessage
@dynamic conditions, summary, timeOfDay;

+ (NSDictionary<NSString *, NSString *> *)propertyToJSONKeyMap {
  return @{ @"timeOfDay" : @"time_of_day" };
}

@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelForecastMessagesSwellMessage
//

@implementation GTLRHackwinds_ModelForecastMessagesSwellMessage
@dynamic compassDirection, direction, period, unit, waveHeight;

+ (NSDictionary<NSString *, NSString *> *)propertyToJSONKeyMap {
  NSDictionary<NSString *, NSString *> *map = @{
    @"compassDirection" : @"compass_direction",
    @"waveHeight" : @"wave_height"
  };
  return map;
}

@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelForecastMessagesUnitLabelMessage
//

@implementation GTLRHackwinds_ModelForecastMessagesUnitLabelMessage
@dynamic measurements, unit;

+ (NSDictionary<NSString *, Class> *)arrayPropertyToClassMap {
  NSDictionary<NSString *, Class> *map = @{
    @"measurements" : [GTLRHackwinds_ModelForecastMessagesMeasurementLabelMessage class]
  };
  return map;
}

@end


// ----------------------------------------------------------------------------
//
//   GTLRHackwinds_ModelForecastMessagesWaveSpectraMessage
//

@implementation GTLRHackwinds_ModelForecastMessagesWaveSpectraMessage
@dynamic angle, energy, frequency, seperationFrequency;

+ (NSDictionary<NSString *, NSString *> *)propertyToJSONKeyMap {
  return @{ @"seperationFrequency" : @"seperation_frequency" };
}

+ (NSDictionary<NSString *, Class> *)arrayPropertyToClassMap {
  NSDictionary<NSString *, Class> *map = @{
    @"angle" : [NSNumber class],
    @"energy" : [NSNumber class],
    @"frequency" : [NSNumber class]
  };
  return map;
}

@end
