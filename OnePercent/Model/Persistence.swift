//
//  Persistence.swift
//  OnePercent
//
//  Created by 霍然 on 3/1/23.
//

import CoreData

class PersistenceController: ObservableObject {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        var item_id = 0
        // Create some current progress
        for index in 0..<3 {
            let newItem = AimTracker(context: viewContext)
            newItem.start_date = Date()
            newItem.title = "Current Aim " + String(item_id)
            newItem.total_progress = 5
            newItem.default_step = 1
            newItem.id = UUID()
            newItem.order = Int64(item_id)
            item_id += 1
        }
        // Create some completed progress
        for index in 0..<3 {
            let newItem = AimTracker(context: viewContext)
            newItem.start_date = Date()
            newItem.end_date = Date()
            newItem.title = "Completed Aim " + String(item_id)
            newItem.total_progress = 5
            newItem.default_step = 1
            newItem.is_completed = true
            newItem.id = UUID()
            item_id += 1
        }
        save(context: viewContext)
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "OnePercent")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension AimTracker {
    static func sampleForPreview() -> AimTracker {
        let tracker = AimTracker(context: PersistenceController.preview.container.viewContext)
        tracker.title = "Sample Task"
        tracker.is_completed = false
        tracker.curr_progress = 0
        tracker.total_progress = 100
        tracker.default_step = 5
        tracker.start_date = Date()
        tracker.id = UUID()
        return tracker
    }
}
