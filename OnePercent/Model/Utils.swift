//
//  Utils.swift
//  OnePercent
//
//  Created by 霍然 on 3/10/23.
//

import Foundation

/*
 * Time related
 */

private let calendar = Calendar.current
private let currentDate = Date()
//let futureDate : Date = calendar.date(byAdding: .day, value: 100, to: currentDate)!

let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
} ()

func timeFormatted(_ totalSeconds: Int) -> String {
    let hours: Int = totalSeconds / 3600
    let minutes: Int = (totalSeconds % 3600) / 60
    let seconds: Int = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

/*
 * Notification related
 */

// TODO: (late) figure out these later

import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { didAllow, error in
        if let error = error {
            print("Error requesting notification permission: \(error)")
        }
    }
}

func scheduleNotification(withTimeInterval timeInterval: TimeInterval, title: String, body: String) {
    requestNotificationPermission()
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        }
    }
}

