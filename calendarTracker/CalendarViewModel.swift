//
//  CalendarViewModel.swift
//  calendarTracker
//
//  Created by Clive on 25/09/2024.
//

import Foundation
import EventKit
import SwiftUI


class CalendarViewModel: ObservableObject {
    @Published var calendarEvents: [EKEvent] = []
     let store = EKEventStore()
    var totalMinutes:Double = 0.0
    
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            print("Calendar access not determined")
            requestAccess()
        case .authorized:
            print("Calendar access authorized")
            fetchPreviousEvents()
        case .denied:
            print("Calendar access denied")
        case .restricted:
            print("Calendar access restricted")
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }
    
    
    // Request access to the calendar
    func requestAccess() {
        store.requestAccess(to: .event, completion:
             {(granted: Bool, error: Error?) -> Void in
                 if granted {
                     self.fetchPreviousEvents()
                 } else {
                   print("Access denied")
                 }
           })
        }
    
    // calculate duration
    func duration(of event: EKEvent) -> Double {
            let durationSecs = event.endDate.timeIntervalSince(event.startDate)
//            let hours = Int(durationInSeconds) / 3600
//            let minutes = (Int(durationInSeconds) % 3600) / 60
        
            return durationSecs
        }
    
    // Fetch previous events from the calendar
    func fetchPreviousEvents() {
        let calendars = store.calendars(for: .event)
        
        // Specify the date range for fetching past events (e.g., last 1 year)
//        let now = Date()
//        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
        
        guard let interval = Calendar.current.dateInterval(of: .month, for: Date()) else {return}
        
        // Create a predicate to search within the date range
        let predicate = store.predicateForEvents(withStart: interval.start, end: interval.end, calendars: calendars)
        
        // Fetch the events
        let events = store.events(matching: predicate)
        
        for event in events {
            if event.isAllDay{
                continue
            }
            totalMinutes += duration(of: event)
            
        }
        
        // Update the @Published array
        DispatchQueue.main.async {
            self.calendarEvents = events.sorted { $0.compareStartDate(with: $1) == .orderedDescending }
        }
    }
}
