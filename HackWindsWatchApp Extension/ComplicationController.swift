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
                DispatchQueue.main.async(execute: {
                    let server=CLKComplicationServer.sharedInstance()
                    
                    for complication in server.activeComplications! {
                        server.reloadTimeline(for: complication)
                    }
                })
            }
        }
        
        if updateManager.doesTideNeedUpdate() {
            updateManager.fetchTideUpdate { (Void) -> Void in
                DispatchQueue.main.async(execute: {
                    let server=CLKComplicationServer.sharedInstance()
                    
                    for complication in server.activeComplications! {
                        server.reloadTimeline(for: complication)
                    }
                })
            }
        }
    }
    
    func requestedUpdateBudgetExhausted() {

    }
    
    func reloadTimelineForComplication(_ complication: CLKComplication!) {

    }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        
        // For now no time traval is supported. Eventually we could be able to provide it with future tides or past buoy data
        handler(CLKComplicationTimeTravelDirections())
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date())
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date())
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        
        var longBuoyText = "-- ft @ -- s ---"
        var waveHeightBuoyText = "-- ft"
        var buoyLocationText = "-------"
        var longTideText = "---- ----: --:-- --"
        var shortTideEventText = "----"
        var tideTime  = Date()
        
        if let buoy = updateManager.latestBuoy {
            longBuoyText = buoy.getSimpleSwellText()
            waveHeightBuoyText = buoy.getWaveHeightText()
        }
        
        if let buoyLocation = updateManager.buoyLocation {
            buoyLocationText = buoyLocation as String
        }
        
        if let tide = updateManager.nextTide {
            longTideText = tide.getEventSummary()
            shortTideEventText = tide.getEventAbbreviation()
            tideTime = tide.timestamp
        }
        
        switch complication.family {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: longBuoyText)
            template.headerTextProvider.tintColor = UIColor(red:0.278, green:0.639, blue:1.0, alpha:1.0)
            template.body1TextProvider = CLKSimpleTextProvider(text: buoyLocationText)
            template.body2TextProvider = CLKSimpleTextProvider(text: longTideText)
            
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: shortTideEventText)
            template.line1TextProvider.tintColor = UIColor(red:0.278, green:0.639, blue:1.0, alpha:1.0)
            template.line2TextProvider = CLKTimeTextProvider(date: tideTime)
            
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text:longBuoyText)
            
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: longBuoyText, shortText: waveHeightBuoyText)
            
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: shortTideEventText)
            template.line2TextProvider = CLKTimeTextProvider(date: tideTime)
            
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
        default:
            return
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: (@escaping ([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler([])
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: (@escaping ([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(Date(timeIntervalSinceNow: 60*30));
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family {
        case .modularSmall:
            let smallModularTemplate = CLKComplicationTemplateModularSmallStackText()
            smallModularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
            smallModularTemplate.line2TextProvider = CLKTimeTextProvider(date: Date())
            handler(smallModularTemplate)
        case .modularLarge:
            let largeModularTemplate = CLKComplicationTemplateModularLargeStandardBody()
            largeModularTemplate.headerTextProvider = CLKSimpleTextProvider(text: "-- ft @ - s --")
            largeModularTemplate.body1TextProvider = CLKSimpleTextProvider(text: "---- ----: --:-- --")
            largeModularTemplate.body2TextProvider = CLKSimpleTextProvider(text: "")
            handler(largeModularTemplate)
        case .utilitarianSmall:
            let smallUtilitarianTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            smallUtilitarianTemplate.textProvider = CLKSimpleTextProvider(text: "-- ft")
            handler(smallUtilitarianTemplate)
        case .utilitarianLarge:
            let largeUtilitarianTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            largeUtilitarianTemplate.textProvider = CLKSimpleTextProvider(text: "-- ft @ -- s ---")
            handler(largeUtilitarianTemplate)
        case .circularSmall:
            let circularTemplate = CLKComplicationTemplateCircularSmallStackText()
            circularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
            circularTemplate.line2TextProvider = CLKTimeTextProvider(date: Date())
            handler(circularTemplate)
        default:
            return
        }
    }
    
}
