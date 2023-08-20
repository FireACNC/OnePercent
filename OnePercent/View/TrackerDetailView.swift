//
//  TrackerDetailView.swift
//  OnePercent
//
//  Created by 霍然 on 7/2/23.
//

import SwiftUI

struct TrackerDetailView: View {
    let tracker: AimTracker
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var congratsPageController: CongratsPageController
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AimTracker.order, ascending: true)],
        predicate: NSPredicate(format: "is_completed == %@", NSNumber(value: false)),
        animation: .default)
    private var items: FetchedResults<AimTracker>

    @State private var currentProgress: Int
    @State private var isEditing = false
    
    init(tracker: AimTracker) {
        self.tracker = tracker
        _currentProgress = State(initialValue: Int(tracker.curr_progress))
    }
    
    var body: some View {
        let startDate = tracker.start_date ?? Date(timeIntervalSince1970: 0)
        let endDate = tracker.start_date ?? Date(timeIntervalSince1970: 0)

        let general_detail = """
            Title: \(tracker.title ?? "")
            Current Progress: \(currentProgress)
            Total Progress: \(tracker.total_progress)
            Started on: \(itemDateFormatter.string(from: startDate))
            Time Spent: \(timeFormatted(Int(tracker.time_spent)))
            Limit Time Aim: \(tracker.limit_time ? "Yes" : "No")
            Increment by Timer Only: \(tracker.timer_only ? "Yes" : "No")
            Minimum Time Selection: \(minTimeOptions[Int(tracker.min_time_index)])
            Challenger Mode: \(tracker.challenger ? "Enabled" : "Disabled")
            
            - Debug use
            Order: \(tracker.order)
            """
        
        let completed_detail = """
            Completed on: \(itemDateFormatter.string(from: endDate))
            """
        
        let detail = tracker.is_completed ? general_detail + "\n" + completed_detail : general_detail
        
        VStack {
            Text(detail)
            
            if !tracker.is_completed {
                if !tracker.timer_only {
                    Button(action: {
                        incrementProgress()
                        if tracker.curr_progress >= tracker.total_progress {
                            congratsPageController.completedAimTitle = tracker.title!
                            congratsPageController.isShowingCongratsPage = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                completeTracker(tracker: tracker, from: viewContext, items: items)
                                self.presentationMode.wrappedValue.dismiss()
                                // TODO: (late) maybe add a guide for checking complete?
                            }
                        }
                    }) {
                        Text("Increment Progress")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Text("You can only increment the progress via the timer.")
                        .padding()
                }
            }
            
            // There's a bug if add toolbar to the navigation link, it may sometimes show duplicated toolbar and thus have a glitch.
            if !tracker.challenger {
                Button(action: {
                    isEditing = true
                }) {
                    Text("Edit")
                }
                .padding()
            }
            
            Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
                Text("Custom go back")
            }
        }
        .sheet(isPresented: $isEditing) {
            EditOrCreateTrackerView(trackerToEdit: tracker)
                .environment(\.managedObjectContext, viewContext)
        }
        .navigationBarBackButtonHidden(true)
        
        // Nav bar back button?
//        .navigationBarItems(leading:
//            Button(action: { self.presentationMode.wrappedValue.dismiss()}) {
//                Text("Custom go back")
//            }
//        )
    }
    
    private func incrementProgress() {
        tracker.curr_progress += tracker.default_step
        currentProgress = Int(tracker.curr_progress)
        save(context: viewContext)

    }
}

// Enable Swipe Back Action
// https://stackoverflow.com/questions/59234958/swiftui-navigationbarbackbuttonhidden-swipe-back-gesture

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

    // To make it works also with ScrollView
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

//struct TrackerDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackerDetailView()
//    }
//}

struct TrackerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

