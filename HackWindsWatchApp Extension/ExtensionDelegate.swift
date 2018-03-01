//
//  ExtensionDelegate.swift
//  HackWindsWatchApp Extension
//
//  Created by Matthew Iannucci on 12/18/15.
//  Copyright © 2015 Rhodysurf Development. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate, URLSessionDownloadDelegate {
    
    let updateManager: WidgetUpdateManager = WidgetUpdateManager.sharedInstance
    
    var pendingURLTask: WKRefreshBackgroundTask? = nil

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        WatchSessionManager.sharedManager.startSession()
    
        scheduleBackgroundRefreshNow()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    // WKExtensionDelegate
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                if self.updateManager.doesBuoyNeedUpdate() {
                    scheduleBuoyURLSession()
                    scheduleFutureBackgroundRefresh()
                }
                
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: urlSessionTask.sessionIdentifier)
                let backgroundSession = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil)
                print("Rejoining session ", backgroundSession)
                
                self.pendingURLTask = urlSessionTask
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    // URLSessionDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Received downloaded data")
        
        let rawData = NSData(contentsOf: location as URL)
        if let rawBuoyData = rawData as Data? {
            self.updateManager.addLatestRawBuoyData(rawData: rawBuoyData)
            print("Added Latest Data")
            
            sendComplicationUpdate()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // TODO: Handle errors?
        if let err = error {
            print("Error downloading data: \(err)")
        } else {
            print("Successfully downloaded data")
        }
        
        self.pendingURLTask?.setTaskCompleted()
        self.pendingURLTask = nil;
    }
    
    // Conveinence methods
    
    func scheduleBackgroundRefreshNow() {
        let updateTime = Date(timeIntervalSinceNow: 5)
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: updateTime, userInfo: nil) { (error: Error?) in
            if let error = error {
                NSLog("Error occured while scheduling background refresh: \(error.localizedDescription)")
            } else {
                NSLog("Background Refresh Scheduled for \(updateTime)")
            }
        }
    }
    
    func scheduleFutureBackgroundRefresh() {
        let updateTime = Date(timeIntervalSinceNow: 60*30)
        NSLog("Next update is at \(updateTime)")
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: updateTime, userInfo: nil) { (error: Error?) in
            if let error = error {
                NSLog("Error occured while scheduling background refresh: \(error.localizedDescription)")
            } else {
                NSLog("Background Refresh Scheduled for \(updateTime)")
            }
        }
    }
    
    func scheduleBuoyURLSession() {
        print("Creating download session")
        let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: NSUUID().uuidString)
        let backgroundSession = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil)
        let buoyDownloadTask = backgroundSession.downloadTask(with: self.updateManager.fetchBuoyUpdateRequest() as URLRequest)
        buoyDownloadTask.resume()
    }
    
    func sendComplicationUpdate() {
        NSLog("Sending complication update")
        
        let server=CLKComplicationServer.sharedInstance()
        if let activeComplications = server.activeComplications {
            for complication in activeComplications {
                NSLog("Updating complication")
                server.reloadTimeline(for: complication)
            }
        }
    }

}
