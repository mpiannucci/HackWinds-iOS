//
//  AppDelegate.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "Reachability.h"
#import <HackWindsDataKit/HackWindsDataKit.h>
#import "WatchSessionManager.h"


@implementation AppDelegate
{
    BOOL _isFullScreen;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidChangeStatusBarOrientationNotification:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    // Use these to set the color of the nav bar and tab bar
    [[UINavigationBar appearance] setBarTintColor:HACKWINDS_BLUE_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UITabBar appearance] setTintColor:HACKWINDS_BLUE_COLOR];

    // Check for network connectivity. If theres no network, show a dialog.
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    // Set the settings plist
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"UISettings" ofType:@"plist"];
    NSUserDefaults *defaultPreferences = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
    [defaultPreferences registerDefaults:[NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile]];
    [defaultPreferences synchronize];
    
    [defaultPreferences setObject:BLOCK_ISLAND_LOCATION forKey:@"BuoyLocation"];
    NSInteger runCount = [defaultPreferences integerForKey:@"RunCount"];
    if (runCount < 10) {
        [defaultPreferences setInteger:runCount+1 forKey:@"RunCount"];
        [defaultPreferences synchronize];
    }
   
    // Let the user know if anything went wrong
    if (networkStatus == NotReachable) {
        NSLog(@"No internet connection");
        return YES;
    }       

    // Load the camera URLs
    CameraModel *cameraModel = [CameraModel sharedModel];
    [cameraModel forceFetchCameraURLs];
    
    // Load all the of the models!!
    [[ForecastModel sharedModel] fetchForecastData];
    [[TideModel sharedModel] fetchTideData];
    
    // Assume Montauk is always active for now
    [[BuoyModel sharedModel] fetchBuoyActive:^(bool active) {
        if (active) {
            [defaultPreferences setObject:BLOCK_ISLAND_LOCATION forKey:@"DefaultBuoyLocation"];
            [defaultPreferences synchronize];
            [[BuoyModel sharedModel] fetchBuoyData];
        } else {
            [defaultPreferences setObject:MONTAUK_LOCATION forKey:@"BuoyLocation"];
            [defaultPreferences synchronize];
            
            // Tell everyone the data has updated
            [[BuoyModel sharedModel] changeBuoyLocation];
            [[BuoyModel sharedModel] fetchBuoyActive:^(bool active) {
                if (active) {
                    [defaultPreferences setObject:MONTAUK_LOCATION forKey:@"DefaultBuoyLocation"];
                    [defaultPreferences synchronize];
                } else {
                    [defaultPreferences setObject:NANTUCKET_LOCATION forKey:@"DefaultBuoyLocation"];
                    [defaultPreferences setObject:NANTUCKET_LOCATION forKey:@"BuoyLocation"];
                    [defaultPreferences synchronize];
                    
                    [[BuoyModel sharedModel] changeBuoyLocation];
                }
                [[BuoyModel sharedModel] fetchBuoyData];
            }];
            
        }
        WatchSessionManager *watchManager = [WatchSessionManager sharedManager];
        [watchManager startSession];
    }];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // Reload all of the models!!
    [[ForecastModel sharedModel] fetchForecastData];
    [[BuoyModel sharedModel] fetchBuoyData];
    [[TideModel sharedModel] fetchTideData];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    NSString *code = [[url host] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    if ([code isEqualToString:@"surfing"]) {
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mpiannucci.HackWinds"];
        [defaults setBool:YES forKey:@"ShowPremiumContent"];
        [defaults synchronize];
        
        [[CameraModel sharedModel] forceFetchCameraURLs];
    }
    
    return YES;
}

- (void)handleDidChangeStatusBarOrientationNotification:(NSNotification *)notification;
{
    
//    if ([[notification.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue] != UIInterfaceOrientationPortrait) {
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    }
}

@end
