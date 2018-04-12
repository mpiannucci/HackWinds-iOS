// NOTE: This file was generated by the ServiceGenerator.

// ----------------------------------------------------------------------------
// API:
//   hackwinds/v1
// Description:
//   This is an API

#import <GoogleAPIClientForREST/GTLRQuery.h>

#if GTLR_RUNTIME_VERSION != 3000
#error This file was generated by a different version of ServiceGenerator which is incompatible with this GTLR library source.
#endif

// Generated comments include content from the discovery document; avoid them
// causing warnings since clang's checks are some what arbitrary.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Parent class for other Hackwinds query classes.
 */
@interface GTLRHackwindsQuery : GTLRQuery

/** Selector specifying which fields to include in a partial response. */
@property(nonatomic, copy, nullable) NSString *fields;

@end

/**
 *  GTLRHackwindsQuery_CameraCameras
 *
 *  Method: hackwinds.camera.cameras
 *
 *  Authorization scope(s):
 *    @c kGTLRAuthScopeHackwindsUserinfoEmail
 */
@interface GTLRHackwindsQuery_CameraCameras : GTLRHackwindsQuery
// Previous library name was
//   +[GTLQueryHackwinds queryForCameraCamerasWithpremium:]

@property(nonatomic, assign) BOOL premium;

/**
 *  Fetches a @c GTLRHackwinds_ModelCameraMessagesCameraLocationsMessage.
 *
 *  @param premium BOOL
 *
 *  @returns GTLRHackwindsQuery_CameraCameras
 */
+ (instancetype)queryWithPremium:(BOOL)premium;

@end

/**
 *  GTLRHackwindsQuery_ForecastForecast
 *
 *  Method: hackwinds.forecast.forecast
 *
 *  Authorization scope(s):
 *    @c kGTLRAuthScopeHackwindsUserinfoEmail
 */
@interface GTLRHackwindsQuery_ForecastForecast : GTLRHackwindsQuery
// Previous library name was
//   +[GTLQueryHackwinds queryForForecastForecast]

/**
 *  Fetches a @c GTLRHackwinds_ModelForecastMessagesSurfForecastMessage.
 *
 *  @returns GTLRHackwindsQuery_ForecastForecast
 */
+ (instancetype)query;

@end

NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop