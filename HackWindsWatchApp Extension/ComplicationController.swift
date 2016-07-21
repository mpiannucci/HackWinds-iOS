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
        
        var longBuoyText = "-- ft @ --s ---"
        var longTideText = "---- ----: --:-- --"
        
        if let buoy = updateManager.latestBuoy {
            longBuoyText = buoy.getWaveSummaryStatusText()
        }
        
        if let tide = updateManager.nextTide {
            longTideText = tide.getTideEventSummary()
        }
        
        switch complication.family {
        case .ModularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: longBuoyText)
            template.body1TextProvider = CLKSimpleTextProvider(text: longTideText)
            template.body2TextProvider = CLKSimpleTextProvider(text: "")
            
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(timelineEntry)
        default:
            handler(nil)
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
        var template: CLKComplicationTemplate? = nil
        switch complication.family {
        case .ModularSmall:
            let smallModularTemplate = CLKComplicationTemplateModularSmallStackText()
            smallModularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
            smallModularTemplate.line2TextProvider = CLKTimeTextProvider(date: NSDate())
            template = smallModularTemplate
        case .ModularLarge:
            let largeModularTemplate = CLKComplicationTemplateModularLargeStandardBody()
            largeModularTemplate.headerTextProvider = CLKSimpleTextProvider(text: "-- ft @ -- s --")
            largeModularTemplate.body1TextProvider = CLKSimpleTextProvider(text: "--- tide: --:-- --")
            largeModularTemplate.body2TextProvider = CLKSimpleTextProvider(text: "")
            template = largeModularTemplate
        case .UtilitarianSmall:
            let smallUtilitarian = CLKComplicationTemplateUtilitarianSmallFlat()
            smallUtilitarian.textProvider = CLKSimpleTextProvider(text: "--- --:--")
            template = smallUtilitarian
        case .UtilitarianLarge:
            let largeUtilitarian = CLKComplicationTemplateUtilitarianLargeFlat()
            largeUtilitarian.textProvider = CLKSimpleTextProvider(text: "-- ft @ -- s ---")
            template = largeUtilitarian
        case .CircularSmall:
            let circularTemplate = CLKComplicationTemplateCircularSmallStackText()
            circularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
            circularTemplate.line2TextProvider = CLKTimeTextProvider(date: NSDate())
            template = circularTemplate
        }
        
        handler(template)
    }
    
}
