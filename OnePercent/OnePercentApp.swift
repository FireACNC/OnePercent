//
//  OnePercentApp.swift
//  OnePercent
//
//  Created by 霍然 on 3/1/23.
//

import SwiftUI

@main
struct OnePercentApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
