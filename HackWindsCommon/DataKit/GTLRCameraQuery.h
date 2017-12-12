// NOTE: This file was generated by the ServiceGenerator.

// ----------------------------------------------------------------------------
// API:
//   camera/v1
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
 *  Parent class for other Camera query classes.
 */
@interface GTLRCameraQuery : GTLRQuery

/** Selector specifying which fields to include in a partial response. */
@property(nonatomic, copy, nullable) NSString *fields;

@end

/**
 *  GTLRCameraQuery_Cameras
 *
 *  Method: camera.cameras
 *
 *  Authorization scope(s):
 *    @c kGTLRAuthScopeCameraUserinfoEmail
 */
@interface GTLRCameraQuery_Cameras : GTLRCameraQuery
// Previous library name was
//   +[GTLQueryCamera queryForCameras]

/**
 *  Fetches a @c GTLRCamera_ModelCameraMessagesCameraLocationsMessage.
 *
 *  @returns GTLRCameraQuery_Cameras
 */
+ (instancetype)query;

@end

NS_ASSUME_NONNULL_END

#pragma clang diagnostic pop