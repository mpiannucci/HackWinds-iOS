//
//  TodayViewController.swift
//  HackWindsTodayOSX
//
//  Created by Matthew Iannucci on 1/2/16.
//  Copyright © 2016 Rhodysurf Development. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {
    
    @IBOutlet weak var latestBuoyLabel: NSTextField!
    @IBOutlet weak var buoyLocationLabel: NSTextField!
    @IBOutlet weak var nextTideLabel: NSTextField!
    
    var reporter: Reporter!

    override var nibName: String? {
        return "TodayViewController"
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        self.reporter = Reporter()
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let updated = self.reporter.updateData()
            
            if updated {
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                    self.updateUI()
                }
            }
        }
        
        completionHandler(.NewData)
    }
    
    func updateUI() {
        // Update the UI using reporter
        if let latestBuoy = reporter.latestBuoy {
            latestBuoyLabel.stringValue = "\(latestBuoy.significantWaveHeight) ft @ \(latestBuoy.dominantPeriod) s \(latestBuoy.meanDirection)"
            buoyLocationLabel.stringValue = "\(reporter.buoyLocation!)"
        }
        
        if let nextTide = reporter.nextTide {
            nextTideLabel.stringValue = "\(nextTide.eventType): \(nextTide.timestamp)"
        }
    }

}
