//
//  TodayViewController.swift
//  HackWindsToday
//
//  Created by Matthew Iannucci on 1/11/16.
//  Copyright © 2016 Rhodysurf Development. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var latestBuoyLabel: UILabel!
    @IBOutlet weak var nextTideLabel: UILabel!
    @IBOutlet weak var lastUpdatedButton: UIButton!
    
    // Variables to hold all of the data
    let updateManager = WidgetUpdateManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure the UI is up to date on loading
        updateBuoyUI()
        updateTideUI()
        updateTimeUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        fetchUpdates()
        
        completionHandler(.NewData)
    }
    
    @IBAction func updateDataClicked(sender: AnyObject) {
        // Force an update
        updateManager.resetUpdateTimes()
        fetchUpdates()
    }
    
    func fetchUpdates() {
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
    
    func updateBuoyUI() {
        if let buoy = updateManager.latestBuoy {
            self.latestBuoyLabel.text = buoy.getSimpleSwellText()
        }
        
    }
    
    func updateTideUI() {
        if let tide = updateManager.nextTide {
            self.nextTideLabel.text = tide.getTideEventSummary()
        }
    }
    
    func updateTimeUI() {
        if let location = updateManager.buoyLocation as? String {
            if let updateTime = updateManager.latestRefreshTime() {
                let dateFormatter = NSDateFormatter()
                dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                
                self.lastUpdatedButton.setTitle("\(location): Updated \(dateFormatter.stringFromDate(updateTime))", forState: UIControlState.Normal)
            }
        }
    }
    
}
