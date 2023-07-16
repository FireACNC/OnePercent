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

    @State private var currentProgress: Int
    
    init(tracker: AimTracker) {
        self.tracker = tracker
        _currentProgress = State(initialValue: Int(tracker.curr_progress))
    }
    
    var body: some View {
        VStack {
            Text("""
            Title: \(tracker.title ?? "")
            Current Progress: \(currentProgress)
            Total Progress: \(tracker.total_progress)
            """)
            
            Button(action: {
                incrementProgress()
                if tracker.curr_progress >= tracker.total_progress {
                    congratsPageController.isShowingCongratsPage = true
                    completeTracker()
                    self.presentationMode.wrappedValue.dismiss()
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
    
    private func incrementProgress() {
        tracker.curr_progress += tracker.default_step
        currentProgress = Int(tracker.curr_progress)
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    private func completeTracker() {
        tracker.is_completed = true

        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
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

