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
    
    let updateManager: WidgetUpdateManager = WidgetUpdateManager()

    override var nibName: String? {
        return "TodayViewController"
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        
        // Load the UI before fetching to make everything look seamless
        self.updateBuoyUI()
        self.updateTideUI()
        
        updateManager.fetchBuoyUpdate { (Void) -> Void in
            DispatchQueue.main.async(execute: {
                self.updateBuoyUI()
            })
        }
        
        updateManager.fetchTideUpdate { (Void) -> Void in
            DispatchQueue.main.async(execute: {
                self.updateTideUI()
            })
        }
        
        completionHandler(.newData)
    }
    
    func updateBuoyUI() {
        if let buoy = self.updateManager.latestBuoy {
            self.latestBuoyLabel.stringValue = buoy.getSimpleSwellText()
        }
        
        if let location = self.updateManager.buoyLocation {
            self.buoyLocationLabel.stringValue = location as String
        }
    }
    
    func updateTideUI () {
        if let tide = self.updateManager.nextTide {
            self.nextTideLabel.stringValue = tide.getEventSummary()
        }
    }

}

