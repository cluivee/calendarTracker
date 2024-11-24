//
//  ContentView.swift
//  calendarTracker.iOS
//
//  Created by Clive on 24/11/2024.
//

import SwiftUI

struct ContentViewiOS: View {
    let array = ["banana", "apple", "cherry","banana", "apple", "cherry", "banana", "apple", "cherry", "banana", "apple", "cherry",  ]
    
    var body: some View {
        VStack {
            Text("Hello, Pad Thai!")
                .padding()
            Text("Hello, Clive is the best !")
                .padding()
                .foregroundColor(Color.green)
            List(array, id: \.self) {item in
                Text(item)
            }
        }
        

    }
}

struct ContentViewiOS_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewiOS()
    }
}
