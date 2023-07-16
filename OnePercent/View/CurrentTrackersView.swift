//
//  CurrentTrackersView.swift
//  OnePercent
//
//  Created by 霍然 on 7/14/23.
//

import SwiftUI

struct CurrentTrackersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var congratsPageController: CongratsPageController
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AimTracker.start_date, ascending: true)],
        predicate: NSPredicate(format: "is_completed == %@", NSNumber(value: false)),
        // TODO: customized order
        animation: .default)
    private var items: FetchedResults<AimTracker>
    
    @State private var isShowingAddView = false
    
    var body: some View {
        // TODO: no aim check
        NavigationView {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        isShowingAddView = true
                    }) {
                        Label("Add Aim Tracker", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("My Aim Trackers")
        }
        .fullScreenCover(isPresented: $isShowingAddView) {
            NewTrackerView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
        .fullScreenCover(isPresented: $congratsPageController.isShowingCongratsPage) {
            CongratsPageView()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

struct CurrentTrackersView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
