//
//  SearchBar.swift
//  calendarTracker
//
//  Created by Clive on 28/09/2024.
//

import SwiftUI

struct SearchBar: View {
    
    @State private var tempSearchText = ""
    @Binding var searchText: String
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        HStack(spacing: 0){
            TextField("Search", text: $tempSearchText, onCommit: {
                withAnimation {
                    searchText = tempSearchText
                }
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                withAnimation {
                    searchText = tempSearchText
                }
            }) {
                Text("Search")
            }
//            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing)
            Spacer()
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchText: .constant(""), viewModel: CalendarViewModel())
    }
}
