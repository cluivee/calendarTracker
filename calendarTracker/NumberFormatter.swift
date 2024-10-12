//
//  NumberFormatter.swift
//  calendarTracker
//
//  Created by Clive on 12/10/2024.
//

import Foundation

public extension NumberFormatter {
        
    static let myFormat: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2
        return nf
    }()

    func string(from obj: Double, missing: String = "") -> String {
        string(from: NSNumber(value: obj)) ?? missing
    }
}
