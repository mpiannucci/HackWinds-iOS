//
//  InterfaceController.swift
//  HackWindsWatchApp Extension
//
//  Created by Matthew Iannucci on 12/18/15.
//  Copyright © 2015 Rhodysurf Development. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    // Interface connections
    @IBOutlet var latestBuoyReportLabel: WKInterfaceLabel!
    @IBOutlet var buoyLocationLabel: WKInterfaceLabel!
    @IBOutlet var nextTideLabel: WKInterfaceLabel!
    @IBOutlet var latestTideStatusLabel: WKInterfaceLabel!
    
    // Variables to hold all of the data
    var buoyLocation: NSString!
    var latestBuoyReport: NSString!
    var latestTideStatus: NSString!
    var nextTide: NSString!
    var latestRefreshTime: NSDate!
    var nextBuoyUpdateTime: NSDate!
    var nextTideUpdateTime: NSDate!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func cacheData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.buoyLocation), forKey: "buoyLocation")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestBuoyReport), forKey: "latestBuoyReport")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestTideStatus), forKey: "latestTideStatus")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextTide), forKey: "nextTide")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.latestRefreshTime), forKey: "latestRefreshTime")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextBuoyUpdateTime), forKey: "nextBuoyUpdateTime")
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.nextTideUpdateTime), forKey: "nextTideUpdateTime")
    }
    
    func restoreData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        self.buoyLocation = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("buoyLocation") as! NSData) as! NSString
        self.latestBuoyReport = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("latestBuoyReport") as! NSData) as! NSString
        self.latestTideStatus = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("latestTideReport") as! NSData) as! NSString
        self.nextTide = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("nextTide") as! NSData) as! NSString
        self.latestRefreshTime = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("latestRefreshTime") as! NSData) as! NSDate
        self.nextBuoyUpdateTime = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("nextBuoyUpdateTime") as! NSData) as! NSDate
        self.nextTideUpdateTime = NSKeyedUnarchiver.unarchiveObjectWithData(defaults.objectForKey("nextTideUpdateTime") as! NSData) as! NSDate
    }

}
