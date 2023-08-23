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
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont(name: "CooperHewitt-Heavy", size: 40)!,
            .baselineOffset: -5
        ]
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if items.isEmpty {
                    Text("Time to start a new aim!")
                        .font(Font.custom("LeagueSpartan-Bold", size: 30))
                        .padding()
                } else {
                    List {
                        ForEach(items) { tracker in
                            let bindingPercentage = Binding<Double>(
                                get: { Double(tracker.curr_progress) / Double(tracker.total_progress) },
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
                            deleteTrackers(offsets: indexSet, from: viewContext, items: items, reordering: true)
                        }
                        .onMove { indices, newOffset in reorderTrackers(indices, newOffset: newOffset, from: viewContext, items: items)
                        }
                    }
                    .listStyle(.plain)
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
            .background(Color("color.background"))
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
