//
//  CompletedTrackersView.swift
//  OnePercent
//
//  Created by 霍然 on 8/6/23.
//

import SwiftUI

struct CompletedTrackersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AimTracker.start_date, ascending: true)],
        predicate: NSPredicate(format: "is_completed == %@", NSNumber(value: true)), // Filter for completed trackers
        animation: .default)
    private var items: FetchedResults<AimTracker>

    var body: some View {
        NavigationView {
            VStack {
                if items.isEmpty {
                    Text("Go and complete an aim!")
                        .padding()
                    
                } else {
                    List {
                        ForEach(items) { tracker in
                            NavigationLink(destination: TrackerDetailView(tracker: tracker)) {
                                Text(tracker.title ?? "")
                            }
                        }
                        .onDelete { indexSet in
                            deleteTrackers(offsets: indexSet, from: viewContext, items: items)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .navigationTitle("Completed Trackers")
        }
    }
}


struct CompletedTrackersView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
