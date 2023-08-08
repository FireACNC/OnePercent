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
            }
        }
    }
    
    private func incrementProgress() {
        tracker.curr_progress += tracker.default_step
        currentProgress = Int(tracker.curr_progress)
        save(context: viewContext)

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

