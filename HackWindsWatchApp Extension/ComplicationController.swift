//
//  ComplicationController.swift
//  HackWinds Watch Extension
//
//  Created by Matthew Iannucci on 7/17/16.
//  Copyright © 2016 Rhodysurf Development. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let updateManager: WidgetUpdateManager = WidgetUpdateManager()
    
    // MARK: - Data handling 
    
    func requestedUpdateDidBegin() {
        
        if updateManager.doesBuoyNeedUpdate() {
        
            // Fetch new data and update if successful
            updateManager.fetchBuoyUpdate { (Void) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let server=CLKComplicationServer.sharedInstance()
                    
                    for complication in server.activeComplications! {
                        server.reloadTimelineForComplication(complication)
                    }
                })
            }
        }
        
        if updateManager.doesTideNeedUpdate() {
            updateManager.fetchTideUpdate { (Void) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let server=CLKComplicationServer.sharedInstance()
                    
                    for complication in server.activeComplications! {
                        server.reloadTimelineForComplication(complication)
                    }
                })
            }
        }
    }
    
    func requestedUpdateBudgetExhausted() {

    }
    
    func reloadTimelineForComplication(complication: CLKComplication!) {

    }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        
        // For now no time traval is supported. Eventually we could be able to provide it with future tides or past buoy data
        handler([.None])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(NSDate())
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(NSDate())
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        
        var longBuoyText = "-- ft @ -- s ---"
        var waveHeightBuoyText = "-- ft"
        var buoyLocationText = "-------"
        var longTideText = "---- ----: --:-- --"
        var shortTideEventText = "----"
        var tideTime  = NSDate()
        
        if let buoy = updateManager.latestBuoy {
            longBuoyText = buoy.getSimpleSwellText()
            waveHeightBuoyText = buoy.getWaveHeightText()
        }
        
        if let buoyLocation = updateManager.buoyLocation {
            buoyLocationText = buoyLocation as String
        }
        
        if let tide = updateManager.nextTide {
            longTideText = tide.getTideEventSummary()
            shortTideEventText = tide.getTideEventAbbreviation()
            tideTime = tide.timestamp
        }
        
        switch complication.family {
        case .ModularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: longBuoyText)
            template.headerTextProvider.tintColor = UIColor(red:0.278, green:0.639, blue:1.0, alpha:1.0)
            template.body1TextProvider = CLKSimpleTextProvider(text: buoyLocationText)
            template.body2TextProvider = CLKSimpleTextProvider(text: longTideText)
            
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(timelineEntry)
        case .ModularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: shortTideEventText)
            template.line1TextProvider.tintColor = UIColor(red:0.278, green:0.639, blue:1.0, alpha:1.0)
            template.line2TextProvider = CLKTimeTextProvider(date: tideTime)
            
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(timelineEntry)
        case .UtilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text:longBuoyText)
            
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(timelineEntry)
        case .UtilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: longBuoyText, shortText: waveHeightBuoyText)
            
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(timelineEntry)
        case .CircularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: shortTideEventText)
            template.line2TextProvider = CLKTimeTextProvider(date: tideTime)
            
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(timelineEntry)
        }
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler([])
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(NSDate(timeIntervalSinceNow: 60*30));
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family {
        case .ModularSmall:
            let smallModularTemplate = CLKComplicationTemplateModularSmallStackText()
            smallModularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
            smallModularTemplate.line2TextProvider = CLKTimeTextProvider(date: NSDate())
            handler(smallModularTemplate)
        case .ModularLarge:
            let largeModularTemplate = CLKComplicationTemplateModularLargeStandardBody()
            largeModularTemplate.headerTextProvider = CLKSimpleTextProvider(text: "-- ft @ - s --")
            largeModularTemplate.body1TextProvider = CLKSimpleTextProvider(text: "---- ----: --:-- --")
            largeModularTemplate.body2TextProvider = CLKSimpleTextProvider(text: "")
            handler(largeModularTemplate)
        case .UtilitarianSmall:
            let smallUtilitarianTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            smallUtilitarianTemplate.textProvider = CLKSimpleTextProvider(text: "-- ft")
            handler(smallUtilitarianTemplate)
        case .UtilitarianLarge:
            let largeUtilitarianTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            largeUtilitarianTemplate.textProvider = CLKSimpleTextProvider(text: "-- ft @ -- s ---")
            handler(largeUtilitarianTemplate)
        case .CircularSmall:
            let circularTemplate = CLKComplicationTemplateCircularSmallStackText()
            circularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
            circularTemplate.line2TextProvider = CLKTimeTextProvider(date: NSDate())
            handler(circularTemplate)
        }
    }
    
}
