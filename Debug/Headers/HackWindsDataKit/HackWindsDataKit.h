//
//  Header.h
//  HackWinds
//
//  Created by Matthew Iannucci on 12/20/15.
//  Copyright © 2015 Rhodysurf Development. All rights reserved.
//

#include <UIKit/UIKit.h>

//! Project version number for HackWindsDataKitOSX.
FOUNDATION_EXPORT double HackWindsDataKitVersionNumber;

//! Project version string for HackWindsDataKitOSX.
FOUNDATION_EXPORT const unsigned char HackWindsDataKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HackWindsDataKitOSX/PublicHeader.h>

// Constants
#import <HackWindsDataKit/Colors.h>
#import <HackWindsDataKit/Constants.h>

// Types
#import <HackWindsDataKit/Camera.h>
#import <HackWindsDataKit/Swell.h>
#import <HackWindsDataKit/Forecast.h>
#import <HackWindsDataKit/ForecastDailySummary.h>
#import <HackWindsDataKit/Buoy.h>
#import <HackWindsDataKit/Tide.h>

// Models
#import <HackWindsDataKit/CameraModel.h>
#import <HackWindsDataKit/ForecastModel.h>
#import <HackWindsDataKit/BuoyModel.h>
#import <HackWindsDataKit/TideModel.h>

// Useful abstracted containers
#import <HackWindsDataKit/BuoyDataContainer.h>