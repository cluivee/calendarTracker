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
        
        
        VStack (alignment: .leading){
            MultiSelectPickerView(allItems: viewModel.store.calendars(for: .event), selectedItems: $viewModel.selectedCalendars, selectAll: true)
            
            Text("Start date: \(viewModel.startDate)")
            DatePicker(
                "Start Date",
                selection: $viewModel.startDate,
                displayedComponents: [.date]
            )
            .padding(.horizontal)
            DatePicker(
                "End Date",
                selection: $viewModel.endDate,
                displayedComponents: [.date]
            )
            .padding(.horizontal)
            SearchBar(searchText: $viewModel.searchTerm, viewModel: viewModel)
          
            Text("Number of events: \(viewModel.calendarEvents.count)")
//            Text("Total Duration: \(String(format: "%.2f", viewModel.totalMinutes/3600)) hours")
            Text("Total Duration: \(NumberFormatter.myFormat.string(from: viewModel.totalMinutes/3600)) hours")
            
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
                        
                        Text("Duration: \(NumberFormatter.myFormat.string(from: viewModel.duration(of: event)/3600)) hours")
                        
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


