//
//  ContentView.swift
//  calendarTracker
//
//  Created by Clive on 25/09/2024.
//

import SwiftUI
import EventKit


struct ContentView: View {
    
    @StateObject private var viewModel = CalendarViewModel()
//    @State private var selectedCalendar = Set<String>()
    
    let names = [
        "Cyril","Lana","Mallory","Sterling"
    ]
    
    var body: some View {
        VStack {
            Text("Number of events: \(viewModel.calendarEvents.count)")
            Text("Total Duration: \(String(format: "%.2f", viewModel.totalMinutes/3600)) hours")
            Text("\(String(describing: viewModel.selectedCalendar))")
            DatePicker(
                "Start Date",
                selection: $viewModel.startDate,
                displayedComponents: [.date]
            ).onChange(of: viewModel.startDate) {val in
                viewModel.fetchPreviousEvents()
            }
            DatePicker(
                "End Date",
                selection: $viewModel.endDate,
                displayedComponents: [.date]
            ).onChange(of: viewModel.endDate) {val in
                viewModel.fetchPreviousEvents()
            }
            
            MultiSelectPickerView(allItems: viewModel.store.calendars(for: .event), selectedItems: $viewModel.selectedCalendar, selectAll: true)
            
//            List(viewModel.store.calendars(for: .event), id: \.self, selection: $viewModel.selectedCalendar) { cal in
//                Text(cal.title)
//                    .foregroundColor(Color(cal.color))
//                    .tag(cal.calendarIdentifier)
//            }
            .onChange(of: viewModel.selectedCalendar) {val in
                viewModel.fetchPreviousEvents()
            }
            
            if viewModel.calendarEvents.isEmpty {
                Text("No events found.")
                    .padding()
            } else {
                List(viewModel.calendarEvents, id: \.eventIdentifier) { event in
                    VStack(alignment: .leading) {
                        Text(event.title ?? "No Title")
                            .font(.headline)
                        Text(event.startDate, style: .date)
                        Text(event.startDate, style: .time)
                        Text(event.calendar.title)
                            .foregroundColor(Color(event.calendar.color))
                        // I would like to change the calendar text color to the same as the calendar's color, but foregroundStyle only allows the default colours at the moment
                        //                                .foregroundStyle(.event.calendar.color)
                        
                        Text("Duration: \(String(format: "%.2f", viewModel.duration(of: event)/3600)) hours")
                        
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(minWidth: 300, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            viewModel.checkCalendarAuthorizationStatus()
        }
    }
    
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
