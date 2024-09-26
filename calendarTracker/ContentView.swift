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
    @State var startDate = Date()
        
        var body: some View {
            VStack {
                if viewModel.calendarEvents.isEmpty {
                    Text("No events found.")
                        .padding()
                } else {
                    Text("Number of events: \(viewModel.calendarEvents.count)")
                    Text("Total Duration: \(String(format: "%.2f", viewModel.totalMinutes/3600)) hours")
                    DatePicker(
                            "Start Date",
                            selection: $startDate,
                            displayedComponents: [.date]
                        )
                    List(viewModel.calendarEvents, id: \.eventIdentifier) { event in
                        VStack(alignment: .leading) {
                            Text(event.title ?? "No Title")
                                .font(.headline)
                            Text(event.startDate, style: .date)
                            Text(event.startDate, style: .time)
                            Text(event.calendar.title)
                            // I would like to change the calendar text color to the same as the calendar's color, but foregroundStyle only allows the default colours at the moment
//                                .foregroundStyle(.event.calendar.color)
                            
                            Text("Duration: \(String(format: "%.2f", viewModel.duration(of: event)/3600)) hours")
                            
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .frame(minWidth: 350, minHeight: 600)
            .onAppear {
                viewModel.checkCalendarAuthorizationStatus()
            }
        }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
