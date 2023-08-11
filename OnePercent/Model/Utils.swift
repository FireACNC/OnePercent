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

public let minTimeOptions = ["None", "1 min", "5 mins", "10 mins", "30 mins", "1 hour"]
public let minTimeValues = [0, 60, 300, 600, 1800, 3600]

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

// TODO: update this to also combine daily reminder
// https://www.youtube.com/watch?v=dxe86OWc2mI

import UserNotifications

public let TIMER_NOTIFICATION_IDENTIFIER = "timer_notification_identifier"

func requestScheduleNotification(withTimeInterval timeInterval: TimeInterval, title: String, body: String) {
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .authorized:
            scheduleNotification(withTimeInterval: timeInterval, title: title, body: body)
            return
        case .denied:
            return
        case .notDetermined:
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                if didAllow {
                    scheduleNotification(withTimeInterval: timeInterval, title: title, body: body)
                } else if let error = error {
                    print("Error requesting notification permission: \(error)")
                    return
                }
            }
        default:
            return
        }
    }
}

func scheduleNotification(withTimeInterval timeInterval: TimeInterval, title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
    let request = UNNotificationRequest(identifier: TIMER_NOTIFICATION_IDENTIFIER, content: content, trigger: trigger)
    
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.removePendingNotificationRequests(withIdentifiers: [TIMER_NOTIFICATION_IDENTIFIER])
    notificationCenter.add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        }
    }
}

func removeNotification() {
    // currently only used for timer
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.removePendingNotificationRequests(withIdentifiers: [TIMER_NOTIFICATION_IDENTIFIER])
}
