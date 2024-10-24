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
    
    @AppStorage("startDate") private var appStorageStartDate = Date()
    @AppStorage("endDate") private var appStorageEndDate = Date()
    
    let testArray = ["aa", "ab"]
    
    var body: some View {
        VStack (alignment: .leading){
            MultiSelectPickerView(allItems: viewModel.store.calendars(for: .event), selectedItems: $viewModel.selectedCalendars, selectAll: true)
            HStack (spacing: 0){
                VStack{
                    DatePicker(
                        "Start Date",
                        selection: $viewModel.startDate,
                        displayedComponents: [.date]
                    )
                        .padding(.horizontal)
                        .onChange(of: viewModel.startDate) {val in
                            appStorageStartDate = val
                        }
                    DatePicker(
                        "End Date",
                        selection: $viewModel.endDate,
                        displayedComponents: [.date]
                    )
                        .padding(.horizontal)
                        .onChange(of: viewModel.endDate) {val in
                            appStorageEndDate = val
                        }
                    
                }
                Button(action: {
                    withAnimation {
                        viewModel.startDate = Date()
                        viewModel.endDate = Date()
                    }
                }) {
                    Text("Today")
                }
                .padding(.trailing)
                Spacer()
            }
            SearchBar(searchText: $viewModel.searchTerm, viewModel: viewModel)
            
            Group {
                Text("Number of events: ")
                    .fontWeight(.heavy)
                    .foregroundColor(.accentColor) +
                Text("\(viewModel.calendarEvents.count)")
                    .fontWeight(.heavy)
            }
            .padding(.horizontal)
            .font(.title3)
            
            Group {
                Text("Total Duration: ")
                    .fontWeight(.heavy)
                    .foregroundColor(.accentColor) +
                Text("\(NumberFormatter.myFormat.string(from: viewModel.totalMinutes/3600)) hours")
                    .fontWeight(.heavy)
            }
            .padding(.horizontal)
            .font(.title3)
            
            if viewModel.calendarEvents.isEmpty {
                Text("No events found.")
                    .padding(.horizontal)
                    .padding(.vertical, 4)
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
            restoreAppStorage()
        }
    }
    
    private func restoreAppStorage() {
        viewModel.startDate = appStorageStartDate
        viewModel.endDate = appStorageEndDate
    }
}

// extension to allow dates to be stored in AppStorage
extension Date: RawRepresentable {
    public var rawValue: String {
        ISO8601DateFormatter().string(from: self)
    }
    
    public init?(rawValue: String) {
        guard let date = ISO8601DateFormatter().date(from: rawValue) else {
            return nil
        }
        self = date
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        //            components.second = -1
        guard let nextDay = Calendar.current.date(byAdding: components, to: self) else { return Date() }
        let startOfNextDay = Calendar.current.startOfDay(for: nextDay)
        return startOfNextDay
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


