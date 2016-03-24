//
//  WidgetUpdateManager.swift
//  HackWinds
//
//  Created by Matthew Iannucci on 1/22/16.
//  Copyright © 2016 Rhodysurf Development. All rights reserved.
//

import Foundation

class WidgetUpdateManager {
    
    // Variables to hold all of the data
    var buoyLocation: NSString? = nil
    var latestBuoy: Buoy? = nil
    var nextTide: Tide? = nil
    var latestBuoyRefreshTime: NSDate? = nil
    var latestTideRefreshTime: NSDate? = nil
    var nextBuoyUpdateTime: NSDate? = nil
    var nextTideUpdateTime: NSDate? = nil
    
    init() {
        self.restoreData()
    }
    
    func latestRefreshTime() -> NSDate? {
        if (self.latestBuoyRefreshTime == nil) && (self.latestTideRefreshTime == nil) {
            return nil
        } else if (self.latestBuoyRefreshTime == nil) {
            return self.latestTideRefreshTime
        } else if (self.latestTideRefreshTime == nil) {
            return self.latestBuoyRefreshTime
        }
        
        if self.latestBuoyRefreshTime!.compare(self.latestTideRefreshTime!) == NSComparisonResult.OrderedAscending {
            return self.latestTideRefreshTime
        } else {
            return self.latestBuoyRefreshTime
        }
    }
    
    func resetUpdateTimes() {
        self.nextBuoyUpdateTime = nil
        self.nextTideUpdateTime = nil
    }
    
    func fetchBuoyUpdate(completionHandler: ((Void) -> Void)!) {
        if (doesBuoyNeedUpdate()) {
            BuoyModel.sharedModel().fetchLatestBuoyReadingForLocation(self.buoyLocation as! String, withCompletionHandler: { (newBuoy: Buoy!) -> Void in
                self.latestBuoy = newBuoy
                self.latestBuoyRefreshTime = NSDate()
                self.findNextUpdateTimes()
                self.cacheData()
                
                // Trigger the callback
                completionHandler()
            })
        }
    }
    
    func fetchTideUpdate(completionHandler: ((Void) -> Void)!) {
        if (doesTideNeedUpdate()) {
            TideModel.sharedModel().fetchLatestTidalEventOnly({ (newTide: Tide!) -> Void in
                self.nextTide = newTide
                self.latestTideRefreshTime = NSDate()
                self.findNextUpdateTimes()
                self.cacheData()
                
                // Trigger the callback
                completionHandler()
            })
        }
    }
    
    func doesBuoyNeedUpdate() -> Bool {
        // Get the latest buoy location from the shared settings. Defaults to Montauk
        let groupDefaults = NSUserDefaults.init(suiteName: "group.com.mpiannucci.HackWinds")
        if let newLocation = groupDefaults?.stringForKey("DefaultBuoyLocation") {
            if let buoyLocation = self.buoyLocation {
                if buoyLocation != newLocation {
                    // The location has been changed since the last spin so force a refresh
                    self.buoyLocation = newLocation
                    self.nextBuoyUpdateTime = nil
                }
            } else {
                // A location has not been set yet so force a refresh
                self.buoyLocation = newLocation
                self.nextBuoyUpdateTime = nil
            }
        } else {
            // Just default to montauk if possible
            self.buoyLocation = MONTAUK_LOCATION
            groupDefaults?.setObject(self.buoyLocation, forKey: "DefaultBuoyLocation")
            self.nextBuoyUpdateTime = nil
        }
        
        // Check if the buoy should be updated and get the new data if it should
        let currentDate = NSDate()
        var needUpdate = false
        if self.nextBuoyUpdateTime == nil || self.latestBuoy == nil {
            needUpdate = true
        } else {
            if self.nextBuoyUpdateTime!.compare(currentDate) == NSComparisonResult.OrderedAscending {
                needUpdate = true
            }
        }
        
        return needUpdate
    }
    
    func doesTideNeedUpdate() -> Bool {
        // Check if the tide should be updated and get the new data if it should
        let currentDate = NSDate()
        var needUpdate = false
        if self.nextTideUpdateTime == nil || self.nextTide == nil {
            needUpdate = true
        } else {
            if self.nextTideUpdateTime!.compare(currentDate) == NSComparisonResult.OrderedAscending {
                needUpdate = true
            }
        }
        return needUpdate
    }
    
    func findNextUpdateTimes() {
        if self.latestBuoy == nil || self.nextTide == nil {
            return
        }
        
        self.nextBuoyUpdateTime = self.latestBuoy?.timestamp.dateByAddingTimeInterval(60*60);
        self.nextTideUpdateTime = self.nextTide?.timestamp
    }
    
    func cacheData() {
        let groupDefaults = NSUserDefaults.init(suiteName: "group.com.mpiannucci.HackWinds")
        
        if let defaults = groupDefaults {
            defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.buoyLocation!), forKey: "buoyLocation")
            if self.latestBuoy != nil {
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestBuoy!), forKey: "latestBuoy")
            }
            if self.nextTide != nil {
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextTide!), forKey: "nextTide")
            }
            if self.latestBuoyRefreshTime != nil {
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestBuoyRefreshTime!), forKey: "latestBuoyRefreshTime")
            }
            if self.latestTideRefreshTime != nil {
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestTideRefreshTime!), forKey: "latestTideRefreshTime")
            }
            if self.nextBuoyUpdateTime != nil {
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextBuoyUpdateTime!), forKey: "nextBuoyUpdateTime")
            }
            if self.nextTideUpdateTime != nil {
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextTideUpdateTime!), forKey: "nextTideUpdateTime")
            }
        }
    }
    
    func restoreData() {
        let groupDefaults = NSUserDefaults.init(suiteName: "group.com.mpiannucci.HackWinds")
        
        if let defaults = groupDefaults {
            if let rawBuoyLocation = defaults.objectForKey("buoyLocation") {
                self.buoyLocation = NSKeyedUnarchiver.unarchiveObjectWithData(rawBuoyLocation as! NSData) as? NSString
            }
            if let rawLatestBuoy = defaults.objectForKey("latestBuoy") {
                self.latestBuoy = NSKeyedUnarchiver.unarchiveObjectWithData(rawLatestBuoy as! NSData) as? Buoy
            }
            if let rawNextTide = defaults.objectForKey("nextTide") {
                self.nextTide = NSKeyedUnarchiver.unarchiveObjectWithData(rawNextTide as! NSData) as? Tide
            }
            if let rawLatestBuoyRefreshTime = defaults.objectForKey("latestBuoyRefreshTime") {
                self.latestBuoyRefreshTime = NSKeyedUnarchiver.unarchiveObjectWithData(rawLatestBuoyRefreshTime as! NSData) as? NSDate
            }
            if let rawLatestTideRefreshTime = defaults.objectForKey("latestTideRefreshTime") {
                self.latestTideRefreshTime = NSKeyedUnarchiver.unarchiveObjectWithData(rawLatestTideRefreshTime as! NSData) as? NSDate
            }
            if let rawNextBuoyUpdateTime = defaults.objectForKey("nextBuoyUpdateTime") {
                self.nextBuoyUpdateTime = NSKeyedUnarchiver.unarchiveObjectWithData(rawNextBuoyUpdateTime as! NSData) as? NSDate
            }
            if let rawNextTideUpdateTime = defaults.objectForKey("nextTideUpdateTime") {
                self.nextTideUpdateTime = NSKeyedUnarchiver.unarchiveObjectWithData(rawNextTideUpdateTime as! NSData) as? NSDate
            }
        }
    }
    
    func dateWithHour(hour: Int, minute: Int, second: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components: NSDateComponents = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour], fromDate: NSDate())
        
        if components.hour > 11 && hour < 6 {
            components.day = components.day + 1
        }
        
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return calendar.dateFromComponents(components)!
        
    }
    
    func check24HourClock() -> Bool {
        let locale = NSLocale.currentLocale()
        let dateCheck = NSDateFormatter.dateFormatFromTemplate("j", options: 0, locale: locale)
        return dateCheck?.rangeOfString("a") == nil
    }
}