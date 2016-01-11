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
    
    // Data handler
    var reporter: Reporter!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        reporter = Reporter()
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
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateUI() {
        if let buoy = reporter.latestBuoy {
            self.latestBuoyReportLabel.setText("\(buoy.SignificantWaveHeight) ft @ \(buoy.DominantPeriod)s \(buoy.MeanDirection)")
            self.buoyLocationLabel.setText("\(reporter.buoyLocation!)")
        }
        
        if let tide = reporter.nextTide {
            self.nextTideLabel.setText("\(tide.EventType): \(tide.Time)")
            if tide.EventType == LOW_TIDE_TAG {
                self.latestTideStatusLabel.setText("Outgoing")
            } else {
                self.latestTideStatusLabel.setText("Incoming")
            }
        }
    }

}
