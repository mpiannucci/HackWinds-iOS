//
//  Reporter.swift
//  HackWinds
//
//  Created by Matthew Iannucci on 12/22/15.
//  Copyright © 2015 Rhodysurf Development. All rights reserved.
//

import Foundation

class Reporter {
    
    // Variables to hold all of the data
    var buoyLocation: NSString!
    var latestBuoy: Buoy!
    var latestTideStatus: NSString!
    var nextTide: Tide!
    var latestRefreshTime: NSDate!
    var nextBuoyUpdateTime: NSDate!
    var nextTideUpdateTime: NSDate!
    
    init () {
        self.restoreData()
        
        if self.nextBuoyUpdateTime == nil || self.nextTideUpdateTime == nil {
            updateData()
        }
    }
    
    func updateData() -> Bool {
        let currentDate = NSDate()
        var buoyUpdated = false
        var tideUpdated = false
        
        // Get the latest buoy location from the shared settings
        let groupDefaults = NSUserDefaults.init(suiteName: "group.com.nucc.HackWinds")
        let newLocation = groupDefaults?.stringForKey("DefaultBuoyLocation")
        if newLocation != self.buoyLocation {
            self.buoyLocation = newLocation
            self.nextBuoyUpdateTime = nil
        }
        
        // Check if the buoy hsould be updated and get the new data if it should
        if self.nextBuoyUpdateTime != nil {
            if self.nextBuoyUpdateTime.compare(currentDate) == NSComparisonResult.OrderedAscending {
                // Update the buoy data!
                let newBuoy = BuoyModel.getOnlyLatestBuoyDataForLocation(self.buoyLocation as String)
            
                if newBuoy.Time != self.latestBuoy.Time {
                    self.latestBuoy = newBuoy
                    buoyUpdated = true
                }
            }
        } else {
            self.latestBuoy = BuoyModel.getOnlyLatestBuoyDataForLocation(self.buoyLocation as String)
            buoyUpdated = true
        }
        
        // Check if the tide should be updated and get the new data if it should
        if self.nextTideUpdateTime != nil {
            if self.nextTideUpdateTime.compare(currentDate) == NSComparisonResult.OrderedAscending {
                // Update the tide data!
                self.nextTide = TideModel.getLatestTidalEventOnly()
                tideUpdated = true
            }
        } else {
            self.nextTide = TideModel.getLatestTidalEventOnly()
            tideUpdated = true
        }
        
        /// Just a placeholder
        return buoyUpdated || tideUpdated
    }
    
    func cacheData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.buoyLocation), forKey: "buoyLocation")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestBuoy), forKey: "latestBuoyReport")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestTideStatus), forKey: "latestTideStatus")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextTide), forKey: "nextTide")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestRefreshTime), forKey: "latestRefreshTime")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextBuoyUpdateTime), forKey: "nextBuoyUpdateTime")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextTideUpdateTime), forKey: "nextTideUpdateTime")
    }
    
    func restoreData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        self.buoyLocation = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("buoyLocation") as! NSData) as! NSString
        self.latestBuoy = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("latestBuoy") as! NSData) as! Buoy
        self.latestTideStatus = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("latestTideReport") as! NSData) as! NSString
        self.nextTide = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("nextTide") as! NSData) as! Tide
        self.latestRefreshTime = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("latestRefreshTime") as! NSData) as! NSDate
        self.nextBuoyUpdateTime = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("nextBuoyUpdateTime") as! NSData) as! NSDate
        self.nextTideUpdateTime = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("nextTideUpdateTime") as! NSData) as! NSDate
    }
}