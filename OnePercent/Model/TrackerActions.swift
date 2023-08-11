//
//  File.swift
//  OnePercent
//
//  Created by 霍然 on 3/10/23.
//

import Foundation
import CoreData
import SwiftUI

func save(context: NSManagedObjectContext) {
    do {
        try context.save()
    } catch {
        let nsError = error as NSError
        print("unable to save the data")
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
}

func addTracker(withAttributes attributes: [String: Any], to viewContext: NSManagedObjectContext, items: FetchedResults<AimTracker>) {
    withAnimation {
        let newItem = AimTracker(context: viewContext)
        // Initialize Default Status
        newItem.is_completed = false
        newItem.curr_progress = 0
        newItem.id = UUID()
        newItem.order = Int64(items.count)
        
        for (key, value) in attributes {
//            print(key, value)
            switch key {
            case "title":
                newItem.title = value as? String
            case "total_progress":
                newItem.total_progress = value as? Int64 ?? 100
            case "default_step":
                newItem.default_step = value as? Int64 ?? 1
            case "start_date":
                newItem.start_date = value as? Date ?? Date()
            case "limit_time":
                newItem.limit_time = value as? Bool ?? false
            case "planned_end_date":
                newItem.planned_end_date = value as? Date ?? Date()
            case "timer_only":
                newItem.timer_only = value as? Bool ?? false
            case "min_time_index":
                newItem.min_time_index = value as? Int16 ?? 0
            case "challenger":
                newItem.challenger = value as? Bool ?? false
            default:
                fatalError("Unknown key encountered: \(key)")
            }
        }
        
        save(context: viewContext)
    }
}

// For deleteTrackers: items should be all current (not completed) items if reordering is true.
func deleteTrackers(offsets: IndexSet, from viewContext: NSManagedObjectContext, items: FetchedResults<AimTracker>, reordering: Bool) {
    withAnimation {
        let trackersToDelete = offsets.map { items[$0] }
        let deletedOrder = trackersToDelete.first?.order ?? 0

        for tracker in trackersToDelete {
           viewContext.delete(tracker)
        }

        if (reordering) {
            reorderUponRemoval(items: items, itemOrder: deletedOrder)
        }

        save(context: viewContext)
   }
}

func completeTracker(tracker: AimTracker, from viewContext: NSManagedObjectContext, items: FetchedResults<AimTracker>) {
    tracker.is_completed = true
    tracker.end_date = Date()
    reorderUponRemoval(items: items, itemOrder: tracker.order)
    save(context: viewContext)
}

/* Reorder upon the deletion or completion of an item.
 <items> should be all current trackers.
 <itemOrder> should be the order of the removed item.
 Note that this is a helper function and need to save in viewContext. */
func reorderUponRemoval(items: FetchedResults<AimTracker>, itemOrder: Int64) {
    for (_, tracker) in items.enumerated() {
       if tracker.order > itemOrder {
           tracker.order -= 1
       }
    }
}

func reorderTrackers(_ indices: IndexSet, newOffset: Int, from viewContext: NSManagedObjectContext, items: FetchedResults<AimTracker>) {
    withAnimation {
        var tempItems = items.map { $0 }
        tempItems.move(fromOffsets: indices, toOffset: newOffset)
        for (index, tracker) in tempItems.enumerated() {
            tracker.order = Int64(index)
        }
        save(context: viewContext)
    }
}


