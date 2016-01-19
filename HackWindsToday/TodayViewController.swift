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
    
    var reporter: Reporter!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reporter = Reporter()
        self.updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        updateViewAsync()
        
        completionHandler(.NewData)
    }
    
    @IBAction func updateDataClicked(sender: AnyObject) {
        updateViewAsync()
    }
    
    func updateViewAsync() {
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
    
    func updateUI() {
        // Update the UI using reporter
        if let latestBuoy = reporter.latestBuoy {
            latestBuoyLabel.text = "\(latestBuoy.significantWaveHeight) ft @ \(latestBuoy.dominantPeriod) s \(latestBuoy.meanDirection)"
        }
        
        if let nextTide = reporter.nextTide {
            nextTideLabel.text = "\(nextTide.eventType): \(nextTide.timestamp)"
        }
        
        if let lastUpdateTime = reporter.latestRefreshTime {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            let updatedString = dateFormatter.stringFromDate(lastUpdateTime)
            lastUpdatedButton.setTitle("\(reporter.buoyLocation!): Last updated \(updatedString)", forState: .Normal)
        }
    }
    
}
