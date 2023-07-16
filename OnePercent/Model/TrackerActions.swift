//
//  File.swift
//  OnePercent
//
//  Created by 霍然 on 3/10/23.
//

import Foundation
import CoreData
import SwiftUI


func addTracker(withAttributes attributes: [String: Any], to viewContext: NSManagedObjectContext) {
    withAnimation {
        let newItem = AimTracker(context: viewContext)
        // Initialize Default Status
        newItem.is_archived = false
        newItem.is_completed = false
        newItem.curr_progress = 0
        
        
        for (key, value) in attributes {
            switch key {
            case "title":
                newItem.title = value as? String
            case "total_progress":
                newItem.total_progress = value as? Int64 ?? 100
            case "default_step":
                newItem.default_step = value as? Int64 ?? 1
            case "start_date":
                newItem.start_date = value as? Date ?? Date()
            default:
                fatalError("Unknown key encountered: \(key)")
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

func deleteTrackers(offsets: IndexSet, from viewContext: NSManagedObjectContext, items: FetchedResults<AimTracker>) {
    withAnimation {
        offsets.map { items[$0] }.forEach(viewContext.delete)

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
