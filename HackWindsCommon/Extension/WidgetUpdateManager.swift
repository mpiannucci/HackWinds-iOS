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
    var latestBuoyRefreshTime: Date? = nil
    var latestTideRefreshTime: Date? = nil
    var nextBuoyUpdateTime: Date? = nil
    var nextTideUpdateTime: Date? = nil
    
    init() {
        self.restoreData()
    }
    
    func latestRefreshTime() -> Date? {
        if (self.latestBuoyRefreshTime == nil) && (self.latestTideRefreshTime == nil) {
            return nil
        } else if (self.latestBuoyRefreshTime == nil) {
            return self.latestTideRefreshTime
        } else if (self.latestTideRefreshTime == nil) {
            return self.latestBuoyRefreshTime
        }
        
        if self.latestBuoyRefreshTime!.compare(self.latestTideRefreshTime!) == ComparisonResult.orderedAscending {
            return self.latestTideRefreshTime
        } else {
            return self.latestBuoyRefreshTime
        }
    }
    
    func resetUpdateTimes() {
        self.nextBuoyUpdateTime = nil
        self.nextTideUpdateTime = nil
    }
    
    func fetchBuoyUpdate(_ completionHandler: ((Void) -> Void)!) {
        if (doesBuoyNeedUpdate()) {
            BuoyModel.shared().fetchLatestBuoyReading(forLocation: self.buoyLocation as! String, withCompletionHandler: { (newBuoy: Buoy?) -> Void in
                self.latestBuoy = newBuoy
                self.latestBuoyRefreshTime = Date()
                self.findNextUpdateTimes()
                self.cacheData()
                
                // Trigger the callback
                completionHandler()
            })
        }
    }
    
    func fetchTideUpdate(_ completionHandler: ((Void) -> Void)!) {
        if (doesTideNeedUpdate()) {
            TideModel.shared().fetchLatestTidalEventOnly({ (newTide: Tide?) -> Void in
                self.nextTide = newTide
                self.latestTideRefreshTime = Date()
                self.findNextUpdateTimes()
                self.cacheData()
                
                // Trigger the callback
                completionHandler()
            })
        }
    }
    
    func doesBuoyNeedUpdate() -> Bool {
        // Get the latest buoy location from the shared settings. Defaults to Montauk
        let groupDefaults = UserDefaults.init(suiteName: "group.com.mpiannucci.HackWinds")
        if let newLocation = groupDefaults?.string(forKey: "DefaultBuoyLocation") {
            if let buoyLocation = self.buoyLocation {
                if buoyLocation as String != newLocation {
                    // The location has been changed since the last spin so force a refresh
                    self.buoyLocation = newLocation as NSString?
                    self.nextBuoyUpdateTime = nil
                }
            } else {
                // A location has not been set yet so force a refresh
                self.buoyLocation = newLocation as NSString?
                self.nextBuoyUpdateTime = nil
            }
        } else {
            // Just default to montauk if possible
            self.buoyLocation = BLOCK_ISLAND_LOCATION as NSString?
            groupDefaults?.set(self.buoyLocation, forKey: "DefaultBuoyLocation")
            self.nextBuoyUpdateTime = nil
        }
        
        // Check if the buoy should be updated and get the new data if it should
        let currentDate = Date()
        var needUpdate = false
        if self.nextBuoyUpdateTime == nil || self.latestBuoy == nil {
            needUpdate = true
        } else {
            if self.nextBuoyUpdateTime!.compare(currentDate) == ComparisonResult.orderedAscending {
                needUpdate = true
            }
        }
        
        return needUpdate
    }
    
    func doesTideNeedUpdate() -> Bool {
        // Check if the tide should be updated and get the new data if it should
        let currentDate = Date()
        var needUpdate = false
        if self.nextTideUpdateTime == nil || self.nextTide == nil {
            needUpdate = true
        } else {
            if self.nextTideUpdateTime!.compare(currentDate) == ComparisonResult.orderedAscending {
                needUpdate = true
            }
        }
        return needUpdate
    }
    
    func findNextUpdateTimes() {
        if self.latestBuoy == nil || self.nextTide == nil {
            return
        }
        
        self.nextBuoyUpdateTime = self.latestBuoy?.timestamp.addingTimeInterval(60*60);
        self.nextTideUpdateTime = self.nextTide?.timestamp
    }
    
    func cacheData() {
        let groupDefaults = UserDefaults.init(suiteName: "group.com.mpiannucci.HackWinds")
        
        if let defaults = groupDefaults {
            defaults.set(NSKeyedArchiver.archivedData(withRootObject: self.buoyLocation!), forKey: "buoyLocation")
            if self.latestBuoy != nil {
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: self.latestBuoy!), forKey: "latestBuoy")
            }
            if self.nextTide != nil {
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: self.nextTide!), forKey: "nextTide")
            }
            if self.latestBuoyRefreshTime != nil {
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: self.latestBuoyRefreshTime!), forKey: "latestBuoyRefreshTime")
            }
            if self.latestTideRefreshTime != nil {
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: self.latestTideRefreshTime!), forKey: "latestTideRefreshTime")
            }
            if self.nextBuoyUpdateTime != nil {
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: self.nextBuoyUpdateTime!), forKey: "nextBuoyUpdateTime")
            }
            if self.nextTideUpdateTime != nil {
                defaults.set(NSKeyedArchiver.archivedData(withRootObject: self.nextTideUpdateTime!), forKey: "nextTideUpdateTime")
            }
        }
    }
    
    func restoreData() {
        let groupDefaults = UserDefaults.init(suiteName: "group.com.mpiannucci.HackWinds")
        
        if let defaults = groupDefaults {
            if let rawBuoyLocation = defaults.object(forKey: "buoyLocation") {
                self.buoyLocation = NSKeyedUnarchiver.unarchiveObject(with: rawBuoyLocation as! Data) as? NSString
            }
            if let rawLatestBuoy = defaults.object(forKey: "latestBuoy") {
                self.latestBuoy = NSKeyedUnarchiver.unarchiveObject(with: rawLatestBuoy as! Data) as? Buoy
            }
            if let rawNextTide = defaults.object(forKey: "nextTide") {
                self.nextTide = NSKeyedUnarchiver.unarchiveObject(with: rawNextTide as! Data) as? Tide
            }
            if let rawLatestBuoyRefreshTime = defaults.object(forKey: "latestBuoyRefreshTime") {
                self.latestBuoyRefreshTime = NSKeyedUnarchiver.unarchiveObject(with: rawLatestBuoyRefreshTime as! Data) as? Date
            }
            if let rawLatestTideRefreshTime = defaults.object(forKey: "latestTideRefreshTime") {
                self.latestTideRefreshTime = NSKeyedUnarchiver.unarchiveObject(with: rawLatestTideRefreshTime as! Data) as? Date
            }
            if let rawNextBuoyUpdateTime = defaults.object(forKey: "nextBuoyUpdateTime") {
                self.nextBuoyUpdateTime = NSKeyedUnarchiver.unarchiveObject(with: rawNextBuoyUpdateTime as! Data) as? Date
            }
            if let rawNextTideUpdateTime = defaults.object(forKey: "nextTideUpdateTime") {
                self.nextTideUpdateTime = NSKeyedUnarchiver.unarchiveObject(with: rawNextTideUpdateTime as! Data) as? Date
            }
        }
    }
    
    func dateWithHour(_ hour: Int, minute: Int, second: Int) -> Date {
        let calendar = Calendar.current
        var components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour], from: Date())
        
        if components.hour! > 11 && hour < 6 {
            components.day = components.day! + 1
        }
        
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return calendar.date(from: components)!
        
    }
    
    func check24HourClock() -> Bool {
        let locale = Locale.current
        let dateCheck = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)
        return dateCheck?.range(of: "a") == nil
    }
}
