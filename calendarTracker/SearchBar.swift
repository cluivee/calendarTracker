//
//  SearchBar.swift
//  calendarTracker
//
//  Created by Clive on 28/09/2024.
//

import SwiftUI


struct SearchBar: View {
    
    @Binding var searchText: String
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        TextField("Search", text: $searchText, onCommit: {
            print("on Commit enter key pressed")
                viewModel.fetchPreviousEvents()
        })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            

    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchText: .constant(""), viewModel: CalendarViewModel())
    }
}
