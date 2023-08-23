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
        sortDescriptors: [NSSortDescriptor(keyPath: \AimTracker.end_date, ascending: false)],
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
                            let bindingPercentage = Binding<Double>(
                                get: { 1.0 },
                                set: { _ in }
                            )
                            
                            Text(tracker.title ?? "")
                                .font(Font.custom("CooperHewitt-Bold", size: 30))
                                .foregroundColor(Color("color.text"))
                                .baselineOffset(-5)
                                .padding()
                            
                                .background(
                                    NavigationLink("", destination: TrackerDetailView(tracker: tracker))
                                        .opacity(0)
                                )
                                .listRowBackground(
                                    TaskCardView(tracker: tracker, percentageCompleted: bindingPercentage)
                                )
                                .listRowSeparator(.hidden)
                        }
                        .onDelete { indexSet in
                            deleteTrackers(offsets: indexSet, from: viewContext, items: items, reordering: false)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .navigationTitle("Completed Trackers")
            .background(Color("color.background"))
        }
    }
}


struct CompletedTrackersView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
