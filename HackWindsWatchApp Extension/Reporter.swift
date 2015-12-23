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
    var buoyLocation: NSString? = nil
    var latestBuoy: Buoy? = nil
    var nextTide: Tide? = nil
    var latestRefreshTime: NSDate? = nil
    var nextBuoyUpdateTime: NSDate? = nil
    var nextTideUpdateTime: NSDate? = nil
    
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
        // TODO: This doesn't work yet, and needs to use watch connectivity. For now default to montauk
        let groupDefaults = NSUserDefaults.init(suiteName: "group.com.nucc.HackWinds")
        let newLocation = groupDefaults?.stringForKey("DefaultBuoyLocation")
        if newLocation == nil {
            self.buoyLocation = MONTAUK_LOCATION
            groupDefaults?.setObject(self.buoyLocation, forKey: "DefaultBuoyLocation")
            self.nextBuoyUpdateTime = nil
        } else if newLocation != self.buoyLocation {
            self.buoyLocation = newLocation
            self.nextBuoyUpdateTime = nil
        }
        
        // Check if the buoy hsould be updated and get the new data if it should
        if self.nextBuoyUpdateTime != nil {
            if self.nextBuoyUpdateTime!.compare(currentDate) == NSComparisonResult.OrderedAscending {
                // Update the buoy data!
                let newBuoy = BuoyModel.getOnlyLatestBuoyDataForLocation(self.buoyLocation! as String)
            
                if newBuoy.Time != self.latestBuoy!.Time {
                    self.latestBuoy = newBuoy
                    buoyUpdated = true
                }
            }
        } else {
            self.latestBuoy = BuoyModel.getOnlyLatestBuoyDataForLocation(MONTAUK_LOCATION)
            buoyUpdated = true
        }
        
        // Check if the tide should be updated and get the new data if it should
        if self.nextTideUpdateTime != nil {
            if self.nextTideUpdateTime!.compare(currentDate) == NSComparisonResult.OrderedAscending {
                // Update the tide data!
                self.nextTide = TideModel.getLatestTidalEventOnly()
                tideUpdated = true
            }
        } else {
            self.nextTide = TideModel.getLatestTidalEventOnly()
            tideUpdated = true
        }
        
        // TODO: Get the next update times
        
        // Just a placeholder
        return buoyUpdated || tideUpdated
    }
    
    func findNextUpdateTimes() {
        if self.latestBuoy == nil || self.nextTide == nil {
            return
        }
        
        
    }
    
    func cacheData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.buoyLocation!), forKey: "buoyLocation")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestBuoy!), forKey: "latestBuoyReport")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextTide!), forKey: "nextTide")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestRefreshTime!), forKey: "latestRefreshTime")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextBuoyUpdateTime!), forKey: "nextBuoyUpdateTime")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextTideUpdateTime!), forKey: "nextTideUpdateTime")
    }
    
    func restoreData() {
        //let defaults = NSUserDefaults.standardUserDefaults()
//        self.buoyLocation = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("buoyLocation") as! NSData)! as? NSString
//        self.latestBuoy = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("latestBuoy") as! NSData)! as? Buoy
//        self.latestTideStatus = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("latestTideReport") as! NSData) as? NSString
//        self.nextTide = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("nextTide") as! NSData) as? Tide
//        self.latestRefreshTime = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("latestRefreshTime") as! NSData) as? NSDate
//        self.nextBuoyUpdateTime = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("nextBuoyUpdateTime") as! NSData) as? NSDate
//        self.nextTideUpdateTime = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("nextTideUpdateTime") as! NSData) as? NSDate
    }
}