//
//  CalendarViewModel.swift
//  calendarTracker
//
//  Created by Clive on 25/09/2024.
//

import Foundation
import EventKit
import SwiftUI
import Combine

class CalendarViewModel: ObservableObject {
    
    // For performance reasons, Apple says EKEventStore only fetches events for previous 4 years. If difference between startDate and EndDate is more than 4 years it is shortened to the first 4 years
    var store = EKEventStore()
    var totalMinutes:Double = 0.0
    
    @Published var selectedCalendars: [EKCalendar] = []
    @Published var calendarEvents: [EKEvent] = []
    
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var searchTerm = ""
    
    private var cancellables = Set<AnyCancellable>()
    
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
            self.addSubscribers()
            fetchEvents()
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
                self.addSubscribers()
                self.fetchEvents()
            } else {
                print("Access denied")
            }
        })
    }
    
    // calculating duration
    func duration(of event: EKEvent) -> Double {
        let durationSecs = event.endDate.timeIntervalSince(event.startDate)
        return durationSecs
        
        //            let hours = Int(durationInSeconds) / 3600
        //            let minutes = (Int(durationInSeconds) % 3600) / 60
    }
    
    // calculating totalMinutes
    func calculateTotalDuration(of events: [EKEvent]) {
        
        totalMinutes = 0
        for event in events {
            if event.isAllDay{
                continue
            }
            totalMinutes += duration(of: event)
        }

    }
    
    
    func addSubscribers() {
        $searchTerm
            .combineLatest($selectedCalendars, $startDate, $endDate)
            .map{ (text, calendars, startDate, endDate) -> [EKEvent] in
                
                var predicate = self.store.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
                
                // apparently changing predicate works, but declaring a new variable for predicate does not
                if let fourYearsBeforeEndDate = Calendar.current.date(byAdding: .year, value: -4, to: endDate) {
                    
                    if fourYearsBeforeEndDate > startDate {
                         predicate = self.store.predicateForEvents(withStart: fourYearsBeforeEndDate, end: endDate, calendars: calendars)
                    } else {
                         predicate = self.store.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
                    }
                }
                
//                let predicate = self.store.predicateForEvents(withStart: newDate, end: endDate, calendars: calendars)
                let tempEvents = self.store.events(matching: predicate)
                
                if !(calendars.isEmpty == false) {
                    print("susbcriber selectedCalendar empty")
                    //                    print(String(describing: self.selectedCalendars))
                    return []
                } else if text.isEmpty {
                    print("subscriber searchterm empty")
                    return tempEvents
                } else {
                    print("subscriber searchterm not empty, should be filtering")
                    return tempEvents.filter { $0.title.localizedCaseInsensitiveContains(text)}
                }
                
            }.sink { [weak self] (returnedEvents) in
                self?.calendarEvents = returnedEvents.sorted { $0.compareStartDate(with: $1) == .orderedDescending }
                self?.calculateTotalDuration(of: returnedEvents)
            }
            .store(in: &cancellables)
    }
    

    // Fetch previous events from the calendar. This is now hardly used except for on launch, and maybe could be not used at all, instead maybe use an init
    func fetchEvents() {
        // Specify the date range for fetching past events (e.g., last 1 year)
        //        let now = Date()
        //        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
        
        //        guard let interval = Calendar.current.dateInterval(of: .month, for: Date()) else {return}
        
        // Surely we don't actually need a predicate, we could just filter the events after the initial fetch of the data
        // Create a predicate to search within the date range
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: selectedCalendars)
        let tempEvents = store.events(matching: predicate)
        
        // Use a computed property to filter and fetch events
        var events: [EKEvent] {
            if !(selectedCalendars.isEmpty == false) {
                print("selectedCalendar empty")
                print(String(describing: selectedCalendars))
                return []
            } else if searchTerm.isEmpty {
                print("searchterm empty")
                return tempEvents
            } else {
                print("searchterm not empty, should be filtering")
                return tempEvents.filter { $0.title.localizedCaseInsensitiveContains(searchTerm)}
            }
        }
        
        // TODO: 04/10/24 so fetchevents is being called twice because this updates the calendarevents, which then triggers onChange within the multiselectpickerview which is watching for selectedCalendar changes (well it was, now its just watching a toggle bool but it is still updating twice). OK all of them are calling this twice, so might have to rethink how this updates the viewmodel.
        // Update the @Published array
        DispatchQueue.main.async {
            self.calendarEvents = events.sorted { $0.compareStartDate(with: $1) == .orderedDescending }
        }
    }
}
