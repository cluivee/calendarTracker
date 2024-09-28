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
    var store = EKEventStore()
    var totalMinutes:Double = 0.0
    
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var searchTerm = ""
    
    @Published var selectedCalendars: [EKCalendar] = []
    
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            print("Calendar access not determined")
            requestAccess()
        case .authorized:
            print("Calendar access authorized")
            // this is just populating selectedCalendars when you first launch the app, otherwise selectedCalendars is an empty array
            let calendars = self.store.calendars(for: .event)
            self.selectedCalendars = calendars
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
                     // this is just populating selectedCalendars when you first launch the app, otherwise selectedCalendars is an empty array
                     let calendars = self.store.calendars(for: .event)
                     self.selectedCalendars = calendars
                     print(String(describing: calendars))
                     self.fetchPreviousEvents()
                 } else {
                   print("Access denied")
                 }
           })
        }
    
    // calculating duration
    func duration(of event: EKEvent) -> Double {
            let durationSecs = event.endDate.timeIntervalSince(event.startDate)
//            let hours = Int(durationInSeconds) / 3600
//            let minutes = (Int(durationInSeconds) % 3600) / 60
        
            return durationSecs
        }
    
    // Fetch previous events from the calendar
    func fetchPreviousEvents() {
        // Specify the date range for fetching past events (e.g., last 1 year)
//        let now = Date()
//        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
        
        guard let interval = Calendar.current.dateInterval(of: .month, for: Date()) else {return}
      
        // Surely we don't actually need a predicate, we could just filter the events after the initial fetch of the data
        // Create a predicate to search within the date range
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: selectedCalendars)
        
        
        // Use a computed property to filter and fetch events
        var events: [EKEvent] {
            if !(selectedCalendars.isEmpty == false) {
                print("selectedCalendar empty")
                print(String(describing: selectedCalendars))
                return []
            } else if searchTerm.isEmpty {
                print("searchterm empty")
                return store.events(matching: predicate)
                } else {
                    let tempEvents = store.events(matching: predicate)
                    print("searchterm not empty, should be filtering")
                    return tempEvents.filter { $0.title.localizedCaseInsensitiveContains(searchTerm)}
                }
        }
        
        
//        if selectedCalendar.isEmpty == false {
//            events = store.events(matching: predicate)
//        }
        
        totalMinutes = 0
        
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
