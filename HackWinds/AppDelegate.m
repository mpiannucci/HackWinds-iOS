//
//  AppDelegate.m
//  HackWinds
//
//  Created by Matthew Iannucci on 7/18/14.
//  Copyright (c) 2014 Matthew Iannucci. All rights reserved.
//

#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Reachability.h"

@implementation AppDelegate
{
    BOOL _isFullScreen;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Use these to set the color of the nav bar and tab bar
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.278 green:0.639 blue:1.0 alpha:1.0]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:0.278 green:0.639 blue:1.0 alpha:1.0]];
    
    // We register ourselves to be notified when the movie player enters or exits full screen
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterFullScreen:)
                                                 name:MPMoviePlayerWillEnterFullscreenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willExitFullScreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    // Check for network connectivity. If theres no network, show a dialog.
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"No internet connection");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                message:@"You can't check waves with no internet!!"
                                                delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alert show];
    }
    
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Allowing the movie players to rotate in fullscreen

// These next three methods are hacks to make the landscpae orientation work when playing full screen
// video.
// Handles the media player requesting full screen
- (void)willEnterFullScreen:(NSNotification *)notification
{
    _isFullScreen = YES;
}

// Handles the media player leaving full screen.
- (void)willExitFullScreen:(NSNotification *)notification
{
    _isFullScreen = NO;
}

// Sets the supported orientation based on whether or not the controller is full screen
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (_isFullScreen) {
        // Its full screen, so all rotation
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    } else {
        // Its not full screen so dont allow it to rotate
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end

// This is a workaround just enables white text colour in status bar in iOS 8.1/8/7.1/7
// Dont touch it until things break
// Despite this category says "draw white", colour automatically becomes black on white background w/o additional code
@interface UINavigationController (StatusBarStyle)

@end

@implementation UINavigationController (StatusBarStyle)
- (UIStatusBarStyle)preferredStatusBarStyle {
    // Force light lettering in the status bar
    return UIStatusBarStyleLightContent;
}
@end
