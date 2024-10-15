//
//  MultiSelectPickerView.swift
//  calendarTracker
//
//  Created by Clive on 28/09/2024.
//

import SwiftUI
import EventKit

struct MultiSelectPickerView: View {
    // The list of items we want to show
    @State var allItems: [EKCalendar]

    // Binding to the selected items we want to track
    @Binding var selectedItems: [EKCalendar]
    
    @State var selectAll: Bool

    var body: some View {
        Form {
            List {
                Button(action: {
                    withAnimation {
                        if selectAll {
                            self.selectedItems.removeAll()
                        } else {
                            self.selectedItems.removeAll()
                            self.selectedItems.append(contentsOf: allItems)
                        }
                        selectAll.toggle()
                    }
                    
                }) {
                    HStack {
                        Image(systemName: selectAll ? "checkmark.square" : "square")
                            .font(Font.title2.weight(.bold))
                            .foregroundColor(selectAll ? .blue : Color.secondary)
                            .controlSize(.large)
                        Text(selectAll ? "Deselect All" : "Select All")
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.primary)
                ForEach(allItems, id: \.self) { item in
                    Button(action: {
                        withAnimation {
                            if self.selectedItems.contains(item) {
                                self.selectedItems.removeAll(where: { $0 == item })
                            } else {
                                self.selectedItems.append(item)
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: self.selectedItems.contains(item) ? "checkmark.square" : "square")
                                .font(Font.title2.weight(.bold))
                                .foregroundColor(self.selectedItems.contains(item) ? .blue : Color.secondary)
                                .controlSize(.large)
//                                .opacity(self.selectedItems.contains(item) ? 1.0 : 0.0)
                            Text(item.title)
                                .foregroundColor(Color(item.color))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.primary)
                }
            }
        }.border(.blue)
    }
}

