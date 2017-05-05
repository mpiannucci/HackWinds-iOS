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
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        fetchUpdates()
        
        completionHandler(.newData)
    }
    
    @IBAction func updateDataClicked(_ sender: AnyObject) {
        // Force an update
        updateManager.resetUpdateTimes()
        fetchUpdates()
    }
    
    func fetchUpdates() {
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
    
    func updateBuoyUI() {
        if let buoy = updateManager.latestBuoy {
            self.latestBuoyLabel.text = buoy.getSimpleSwellText()
        }
        
    }
    
    func updateTideUI() {
        if let tide = updateManager.nextTide {
            self.nextTideLabel.text = tide.getEventSummary()
        }
    }
    
    func updateTimeUI() {
        if let location = updateManager.buoyLocation as String? {
            if let updateTime = updateManager.latestRefreshTime() {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.short
                dateFormatter.dateStyle = DateFormatter.Style.short
                
                self.lastUpdatedButton.setTitle("\(location): Updated \(dateFormatter.string(from: updateTime as Date))", for: UIControlState())
            }
        }
    }
    
}
