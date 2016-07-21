//
//  ComplicationController.swift
//  HackWinds Watch Extension
//
//  Created by Matthew Iannucci on 7/17/16.
//  Copyright © 2016 Rhodysurf Development. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
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
        switch complication.family {
        case .ModularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "12 ft @ 6s SSW", shortText: "12 ft 6s SSW")
            template.body1TextProvider = CLKSimpleTextProvider(text: "High Tide @ 12:12 AM", shortText: "High 12:12 AM")
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
        handler(NSDate(timeIntervalSinceNow: 60*60));
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        var template: CLKComplicationTemplate? = nil
        switch complication.family {
        case .ModularSmall:
            let smallModularTemplate = CLKComplicationTemplateModularSmallStackText()
            smallModularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "---")
            smallModularTemplate.line2TextProvider = CLKTimeTextProvider()
            template = smallModularTemplate
        case .ModularLarge:
            let largeModularTemplate = CLKComplicationTemplateModularLargeStandardBody()
            largeModularTemplate.headerTextProvider = CLKSimpleTextProvider(text: "-- ft @ -- s --")
            largeModularTemplate.body1TextProvider = CLKSimpleTextProvider(text: "--- tide @ --:--")
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
            circularTemplate.line2TextProvider = CLKTimeTextProvider()
            template = circularTemplate
        }
        
        handler(template)
    }
    
}
