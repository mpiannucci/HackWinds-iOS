//
//  ExtensionDelegate.swift
//  HackWindsWatchApp Extension
//
//  Created by Matthew Iannucci on 12/18/15.
//  Copyright © 2015 Rhodysurf Development. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    let updateManager: WidgetUpdateManager = WidgetUpdateManager()
    
    var buoyUpdateTaskPending = false
    var tideUpdateTaskPending = true

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        WatchSessionManager.sharedManager.startSession()
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: 5), userInfo: nil) { (error: Error?) in
            if let error = error {
                NSLog("Error occured while scheduling background refresh: \(error.localizedDescription)")
            } else {
                NSLog("Background Refresh Scheduled for \(Date(timeIntervalSinceNow: 5))")
            }
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                self.buoyUpdateTaskPending = self.updateManager.fetchBuoyUpdate { (Void) -> Void in
                    self.buoyUpdateTaskPending = false
                    self.sendComplicationUpdate()
                }
                
                self.tideUpdateTaskPending = self.updateManager.fetchTideUpdate { (Void) -> Void in
                    self.tideUpdateTaskPending = false
                    self.sendComplicationUpdate()
                }
                
                if self.buoyUpdateTaskPending && self.tideUpdateTaskPending {
                    // When fetches are occuring we know when to schedule the next update
                    WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: 60 * 60), userInfo: nil) { (error: Error?) in
                        if let error = error {
                            NSLog("Error occured while scheduling background refresh: \(error.localizedDescription)")
                        } else {
                            NSLog("Background Refresh Scheduled for \(Date(timeIntervalSinceNow: 60 * 60))")
                        }
                    }
                }
                
                // Clean up
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    func sendComplicationUpdate() {
        if self.buoyUpdateTaskPending || self.tideUpdateTaskPending {
            // Dont update complications until all the data is ready
            return
        }
        
        let server=CLKComplicationServer.sharedInstance()
        if let activeComplications = server.activeComplications {
            for complication in activeComplications {
                server.reloadTimeline(for: complication)
            }
        }
    }

}
