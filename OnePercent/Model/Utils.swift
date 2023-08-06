//
//  Utils.swift
//  OnePercent
//
//  Created by 霍然 on 3/10/23.
//

import Foundation

private let calendar = Calendar.current
private let currentDate = Date()
//let futureDate : Date = calendar.date(byAdding: .day, value: 100, to: currentDate)!

let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
} ()
