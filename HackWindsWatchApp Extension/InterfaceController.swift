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
    
    let updateManager: WidgetUpdateManager = WidgetUpdateManager()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Update the interface right away
        updateBuoyUI()
        updateTideUI()
        
        // Fetch new data and update if successful
        updateManager.fetchBuoyUpdate { (Void) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.updateBuoyUI()
            })
        }
        
        updateManager.fetchTideUpdate { (Void) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.updateTideUI()
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
            self.latestBuoyReportLabel.setText(buoy.getWaveSummaryStatusText())
        }
    }
    
    func updateTideUI() {
        if let tide = updateManager.nextTide {
            self.nextTideLabel.setText(tide.getTideEventSummary())
        }
    }

}
