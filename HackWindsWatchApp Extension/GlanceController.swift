//
//  GlanceController.swift
//  HackWindsWatchApp Extension
//
//  Created by Matthew Iannucci on 12/18/15.
//  Copyright © 2015 Rhodysurf Development. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    @IBOutlet var latestBuoyStatusLabel: WKInterfaceLabel!
    @IBOutlet var nextTideStatusLabel: WKInterfaceLabel!
    @IBOutlet var lastUpdateTimeLabel: WKInterfaceLabel!
    
    let updateManager: WidgetUpdateManager = WidgetUpdateManager()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        updateBuoyUI()
        updateTideUI()
        updateTimeUI()
        
        // Fetch new data and update if successful
        updateManager.fetchBuoyUpdate { (Void) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.updateBuoyUI()
                self.updateTimeUI()
            })
        }
        
        updateManager.fetchTideUpdate { (Void) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.updateTideUI()
                self.updateTimeUI()
            })
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
    
    func updateBuoyUI() {
        if let buoy = updateManager.latestBuoy {
            self.latestBuoyStatusLabel.setText(buoy.getWaveSummaryStatusText())
        }
        
        if let lastUpdateTime = updateManager.latestRefreshTime() {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            self.lastUpdateTimeLabel.setText(dateFormatter.stringFromDate(lastUpdateTime))
        }
    }
    
    func updateTideUI() {
        if let tide = updateManager.nextTide {
            self.nextTideStatusLabel.setText(tide.getTideEventSummary())
        }
        
        if let lastUpdateTime = updateManager.latestRefreshTime() {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            self.lastUpdateTimeLabel.setText(dateFormatter.stringFromDate(lastUpdateTime))
        }
    }

    func updateTimeUI() {
        if let lastUpdateTime = updateManager.latestRefreshTime() {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            self.lastUpdateTimeLabel.setText("Last updated at \(dateFormatter.stringFromDate(lastUpdateTime))")
        }
    }
}
