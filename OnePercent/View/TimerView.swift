//
//  TimerView.swift
//  OnePercent
//
//  Created by 霍然 on 8/7/23.
//

import SwiftUI
import SwiftUI

struct TimerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AimTracker.start_date, ascending: true)],
        predicate: NSPredicate(format: "is_completed == %@", NSNumber(value: false)),
        animation: .default)
    private var items: FetchedResults<AimTracker>

    @State private var selectedTracker: AimTracker?
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var isTimerRunning = false
    @State private var timerValue = 0
    @State private var timer: Timer?

    var body: some View {
        VStack {
            // Aim selection
            Picker("Select Aim", selection: $selectedTracker) {
                ForEach(items) { tracker in
                    Text(tracker.title ?? "")
                }
            }
            .pickerStyle(.menu)
            .padding()

            // Timer display
            Text("\(timeFormatted(timerValue))")
                .font(.largeTitle)
                .padding()

            // Custom time selection
            HStack {
                TimerNumberPicker(title: "Hours", value: $hours, range: 0...4)
                TimerNumberPicker(title: "Minutes", value: $minutes, range: 0...59)
                TimerNumberPicker(title: "Seconds", value: $seconds, range: 0...59)
            }
            .padding()

            // Start and reset buttons
            HStack {
                if !isTimerRunning {
                    Button(action: startTimer) {
                        Text("Start")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: resetTimer) {
                        Text("Reset")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: cancelTimer) {
                        Text("Cancel")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Timer")
    }

    private func timeFormatted(_ totalSeconds: Int) -> String {
        let hours: Int = totalSeconds / 3600
        let minutes: Int = (totalSeconds % 3600) / 60
        let seconds: Int = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func startTimer() {
        guard let selectedTracker = selectedTracker else { return }
        let totalTimeInSeconds = hours * 3600 + minutes * 60 + seconds
        timerValue = totalTimeInSeconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timerValue > 0 {
                timerValue -= 1
            } else {
                timer?.invalidate()
                incrementAimProgress()
            }
        }
        isTimerRunning = true
    }

    private func resetTimer() {
        timer?.invalidate()
        isTimerRunning = false
        timerValue = 0
    }

    private func cancelTimer() {
        timer?.invalidate()
        isTimerRunning = false
        timerValue = 0
    }

    private func incrementAimProgress() {
        guard let selectedTracker = selectedTracker else { return }
        selectedTracker.curr_progress += selectedTracker.default_step
        save(context: viewContext)
    }
}

struct TimerNumberPicker: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Stepper(value: $value, in: range, label: {
                Text("\(value)")
            })
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
