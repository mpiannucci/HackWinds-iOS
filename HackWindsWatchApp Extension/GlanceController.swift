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

    // Interface Connections
    @IBOutlet var latestBuoyReportLabel: WKInterfaceLabel!
    @IBOutlet var nextTideStatusLabel: WKInterfaceLabel!
    @IBOutlet var lastUpdatedTimeLabel: WKInterfaceLabel!
    
    let updateManager: WidgetUpdateManager = WidgetUpdateManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        updateBuoyUI()
        updateTideUI()
        updateTimeUI()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Fetch new data and update if successful
        updateManager.fetchBuoyUpdate { (Void) -> Void in
            DispatchQueue.main.async(execute: {
                self.updateBuoyUI()
                self.updateTimeUI()
            })
        }
        
        updateManager.fetchTideUpdate { (Void) -> Void in
            DispatchQueue.main.async(execute: {
                self.updateTideUI()
                self.updateTimeUI()
            })
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateBuoyUI() {
        if let buoy = updateManager.latestBuoy {
            self.latestBuoyReportLabel.setText(buoy.getWaveSummaryStatusText())
        }
    }
    
    func updateTideUI() {
        if let tide = updateManager.nextTide {
            self.nextTideStatusLabel.setText(tide.getEventSummary())
        }
    }

    func updateTimeUI() {
        if let lastUpdateTime = updateManager.latestRefreshTime() {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short
            dateFormatter.dateStyle = DateFormatter.Style.short
            self.lastUpdatedTimeLabel.setText("Updated \(dateFormatter.string(from: lastUpdateTime as Date))")
        }
    }
}
