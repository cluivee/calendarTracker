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
//    @State var startDate = Date()
        
        var body: some View {
            VStack {
                Text("Number of events: \(viewModel.calendarEvents.count)")
                Text("Total Duration: \(String(format: "%.2f", viewModel.totalMinutes/3600)) hours")
                Text("Start Date: \(viewModel.startDate)")
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
