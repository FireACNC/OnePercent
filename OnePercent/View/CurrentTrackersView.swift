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
        sortDescriptors: [NSSortDescriptor(keyPath: \AimTracker.order, ascending: true)],
        predicate: NSPredicate(format: "is_completed == %@", NSNumber(value: false)),
        animation: .default)
    private var items: FetchedResults<AimTracker>
    
    @State private var isShowingAddView = false
    
    var body: some View {
        NavigationView {
            VStack {
                if items.isEmpty {
                    Text("Time to start a new aim!")
                        .padding()
                } else {
                    List {
                        ForEach(items) { tracker in
                            NavigationLink(destination: TrackerDetailView(tracker: tracker)) {
                                Text(tracker.title ?? "")
                            }
                        }
                        .onDelete { indexSet in
                            deleteTrackers(offsets: indexSet, from: viewContext, items: items, reordering: true)
                        }
                        .onMove { indices, newOffset in reorderTrackers(indices, newOffset: newOffset, from: viewContext, items: items) }
                    }
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
            EditOrCreateTrackerView().environment(\.managedObjectContext, viewContext)
        }
        .fullScreenCover(isPresented: $congratsPageController.isShowingCongratsPage) {
            CongratsPageView()
                .environmentObject(congratsPageController)
        }
    }
}

struct CurrentTrackersView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
