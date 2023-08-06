//
//  ContentView.swift
//  OnePercent
//
//  Created by 霍然 on 3/1/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var congratsPageController = CongratsPageController()
    
    var body: some View {
        NavigationView {
            TabView {
                CurrentTrackersView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(congratsPageController)
                    .tabItem {
                        Label("Trackers", systemImage: "list.bullet")
                    }
                
                Text("Timer")
                    .tabItem {
                        Label("Timer", systemImage: "clock")
                    }
                
                Text("Completed Trackers")
                    .tabItem {
                        Label("Completed", systemImage: "checkmark.circle")
                    }
                
                
                Text("User Profile")
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
                // TODO: archived?
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}