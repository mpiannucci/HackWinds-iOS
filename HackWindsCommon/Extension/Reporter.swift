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
    }
    
    func updateData() -> Bool {
        let currentDate = NSDate()
        var buoyUpdated = false
        var tideUpdated = false
        
        // Get the latest buoy location from the shared settings
        // TODO: This doesn't work yet, and needs to use watch connectivity. For now default to montauk
        let groupDefaults = NSUserDefaults.init(suiteName: "group.com.nucc.HackWinds")
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
        
//        // Check if the buoy should be updated and get the new data if it should
//        if self.nextBuoyUpdateTime == nil || self.latestBuoy == nil {
//            self.latestBuoy = BuoyModel.getOnlyLatestBuoyDataForLocation(MONTAUK_LOCATION)
//            buoyUpdated = true
//        } else {
//            if self.nextBuoyUpdateTime!.compare(currentDate) == NSComparisonResult.OrderedAscending {
//                // Update the buoy data!
//                let newBuoy = BuoyModel.getOnlyLatestBuoyDataForLocation(self.buoyLocation! as String)
//            
//                if newBuoy.timestamp != self.latestBuoy!.timestamp {
//                    self.latestBuoy = newBuoy
//                    buoyUpdated = true
//                }
//            }
//        }
//        
//        // Check if the tide should be updated and get the new data if it should
//        if self.nextTideUpdateTime == nil || self.nextTide == nil {
//            self.nextTide = TideModel.getLatestTidalEventOnly()
//            tideUpdated = true
//        } else {
//            if self.nextTideUpdateTime!.compare(currentDate) == NSComparisonResult.OrderedAscending {
//                // Update the tide data!
//                self.nextTide = TideModel.getLatestTidalEventOnly()
//                tideUpdated = true
//            }
//        }
        
        // Get the next update times
        let updateHappened: Bool = buoyUpdated || tideUpdated
        if updateHappened {
            findNextUpdateTimes()
            self.latestRefreshTime = NSDate()
            cacheData()
        }
        
        return updateHappened
    }
    
    func findNextUpdateTimes() {
        if self.latestBuoy == nil || self.nextTide == nil {
            return
        }
        
        // Find the colon to find te correct hour and minute
        let buoySeperator = self.latestBuoy!.timestamp.rangeOfString(":")
        let tideSeperator = self.nextTide!.timestamp.rangeOfString(":")
        
        // Parse the time from the latest object
        var buoyHour: Int = Int(self.latestBuoy!.timestamp.substringToIndex(buoySeperator!.startIndex))!
        let buoyMinute: Int = Int(self.latestBuoy!.timestamp.substringFromIndex(buoySeperator!.endIndex))!
        var tideHour: Int = Int(self.nextTide!.timestamp.substringToIndex(tideSeperator!.startIndex))!
        let tideMinute: Int = Int(self.nextTide!.timestamp.substringWithRange(Range<String.Index>(start: tideSeperator!.endIndex, end: tideSeperator!.endIndex.advancedBy(2))))!
        
        // Adjust for am and pm during 12 hour time
        if !check24HourClock() {
            // Correct the buoy time
            let currentDate = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "a"
            let buoyAMPM = dateFormatter.stringFromDate(currentDate).lowercaseString
            if buoyAMPM == "pm" && buoyHour != 12 {
                buoyHour += 12
            }
            
            // Correct the tide time
            let tideAMPMIndex = tideSeperator!.startIndex.advancedBy(4)
            let tideAMPM = self.nextTide!.timestamp.substringFromIndex(tideAMPMIndex)
            if tideAMPM == "pm" && tideHour != 12 {
                tideHour += 12
            }
        }
        
        // Set the times that updates are needed at
        self.nextBuoyUpdateTime = dateWithHour(buoyHour, minute: buoyMinute, second: 0)
        self.nextBuoyUpdateTime = self.nextBuoyUpdateTime?.dateByAddingTimeInterval(60 * 60)
        self.nextTideUpdateTime = dateWithHour(tideHour, minute: tideMinute, second: 0)
    }
    
    func cacheData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.buoyLocation!), forKey: "buoyLocation")
        if self.latestBuoy != nil {
            defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestBuoy!), forKey: "latestBuoy")
        }
        if self.nextTide != nil {
            defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextTide!), forKey: "nextTide")
        }
        if self.latestRefreshTime != nil {
            defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestRefreshTime!), forKey: "latestRefreshTime")
        }
        if self.nextBuoyUpdateTime != nil {
            defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextBuoyUpdateTime!), forKey: "nextBuoyUpdateTime")
        }
        if self.nextTideUpdateTime != nil {
            defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextTideUpdateTime!), forKey: "nextTideUpdateTime")
        }
    }
    
    func restoreData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let rawBuoyLocation = defaults.objectForKey("buoyLocation") {
            self.buoyLocation = NSKeyedUnarchiver.unarchiveObjectWithData(rawBuoyLocation as! NSData) as? NSString
        }
        if let rawLatestBuoy = defaults.objectForKey("latestBuoy") {
            self.latestBuoy = NSKeyedUnarchiver.unarchiveObjectWithData(rawLatestBuoy as! NSData) as? Buoy
        }
        if let rawNextTide = defaults.objectForKey("nextTide") {
            self.nextTide = NSKeyedUnarchiver.unarchiveObjectWithData(rawNextTide as! NSData) as? Tide
        }
        if let rawLatestRefreshTime = defaults.objectForKey("latestRefreshTime") {
            self.latestRefreshTime = NSKeyedUnarchiver.unarchiveObjectWithData(rawLatestRefreshTime as! NSData) as? NSDate
        }
        if let rawNextBuoyUpdateTime = defaults.objectForKey("nextBuoyUpdateTime") {
            self.nextBuoyUpdateTime = NSKeyedUnarchiver.unarchiveObjectWithData(rawNextBuoyUpdateTime as! NSData) as? NSDate
        }
        if let rawNextTideUpdateTime = defaults.objectForKey("nextTideUpdateTime") {
            self.nextTideUpdateTime = NSKeyedUnarchiver.unarchiveObjectWithData(rawNextTideUpdateTime as! NSData) as? NSDate
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