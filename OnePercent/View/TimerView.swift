//
//  TimerView.swift
//  OnePercent
//
//  Created by 霍然 on 8/7/23.
//

import SwiftUI
import UserNotifications

struct TimerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var congratsPageController: CongratsPageController
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AimTracker.start_date, ascending: true)],
        predicate: NSPredicate(format: "is_completed == %@", NSNumber(value: false)),
        animation: .default)
    private var items: FetchedResults<AimTracker>

    @State private var selectedTracker: AimTracker?
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var timerValue = 0
    @State private var totalTimeInSeconds = 0
    @State private var timer: DispatchSourceTimer?

    @State private var isTimerRunning = false
    @State private var isTimerStarted = false
    @State private var showClock = false
    @State private var showTimerPicker = true
    @State private var showingCancelConfirmation = false
    @State private var invalidTime = false

    var body: some View {
        VStack {
            // Aim selection
            if (!items.isEmpty) {
                if (!isTimerStarted) {
                    Picker("Select Aim", selection: $selectedTracker) {
                        ForEach(items) { tracker in
                            Text(tracker.title ?? "").tag(tracker as AimTracker?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                } else {
                    Text("\(selectedTracker?.title ?? "")")
                        .padding()
                }
            }

            // Timer display
            if (showClock) {
                Text("\(timeFormatted(timerValue))")
                    .font(.largeTitle)
                    .padding()
            }

            // Custom time selection
            if (showTimerPicker) {
                HStack {
                    TimerNumberPicker(title: "Hours", value: $hours, range: 0...24)
                    TimerNumberPicker(title: "Minutes", value: $minutes, range: 0...59)
                    TimerNumberPicker(title: "Seconds", value: $seconds, range: 0...59)
                }
                .padding()
            }
            
            // Start and reset buttons
            HStack {
                if (!isTimerStarted) {
                    Button(action: startTimer) {
                        Text("Start")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .frame(width: 250, height: 40)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    if (isTimerRunning) {
                        Button(action: pauseTimer) {
                            Text("Pause")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        Button(action: resumeTimer) {
                            Text("Resume")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    Button(action: {
                        // prevent from crashing if cancel when the timer goes off
                        if (timerValue <= 1) {
                            return
                        }
                        pauseTimer()
                        showingCancelConfirmation = true
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            
            Text(invalidTime ? "Please select a valid time" : " ")
                .foregroundColor(Color.red)
                .offset(y:-15)
        }
        .navigationTitle("Timer")
        .onAppear() {
            selectedTracker = items.first
        }
        .alert(isPresented: $showingCancelConfirmation) {
            Alert(
                title: Text("Cancel Timer?"),
                message: Text("Are you sure you want to cancel the timer? The time you just spent will not be recorded!"),
                primaryButton: .default(Text("Cancel")) {
                    resumeTimer()
                },
                secondaryButton: .destructive(Text("Confirm")) {
                    cancelTimer()
                }
            )
        }
        .fullScreenCover(isPresented: $congratsPageController.isShowingCongratsPage) {
            CongratsPageView()
                .environmentObject(congratsPageController)
        }
    }

    private func startTimer() {
        totalTimeInSeconds = hours * 3600 + minutes * 60 + seconds
        
        if (totalTimeInSeconds <= 0) {
            invalidTime = true
            return
        }
        
        invalidTime = false
        timerValue = totalTimeInSeconds
        
        withAnimation {
            isTimerStarted = true
            isTimerRunning = true
        }
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        timer?.setEventHandler { updateTimer() }
        withAnimation {
            showClock = true
            showTimerPicker = false
        }
        timer?.resume()
    }
    
    private func updateTimer() {
        if timerValue > 0 {
            timerValue -= 1
        } else {
            cancelTimer()
            if (selectedTracker != nil) {
                incrementAimProgress()
                if selectedTracker!.curr_progress >= selectedTracker!.total_progress {
                    congratsPageController.completedAimTitle = selectedTracker!.title!
                    congratsPageController.isShowingCongratsPage = true
                    completeTracker(tracker: selectedTracker!, from: viewContext, items: items)
                }
            }
//            scheduleNotification(withTimeInterval: TimeInterval(timerValue), title: "Timer Complete", body: "Your timer has finished!")
        }
    }
        
    private func pauseTimer() {
        timer?.suspend()
        isTimerRunning = false
    }
    
    private func resumeTimer() {
        timer?.resume()
        isTimerRunning = true
    }

    private func cancelTimer() {
        timer?.cancel()
        isTimerRunning = false
        isTimerStarted = false
        withAnimation {
            showClock = false
            showTimerPicker = true
        }
        timerValue = 0
    }

    private func incrementAimProgress() {
        // TODO: (late) add some animation to indicate times up
        // maybe just a banner at the bottom/top
        selectedTracker!.curr_progress += selectedTracker!.default_step
        selectedTracker!.time_spent += Int64(totalTimeInSeconds)
        save(context: viewContext)
        // TODO: (late) integrate with tracker detail view? or simply lock the screen?
        // I'd say locking the screen is a proper way to deal with this
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
            
            Picker("", selection: $value) {
                ForEach(Array(range), id: \.self) { number in
                    Text("\(number)")
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
