//
//  NewAimView.swift
//  OnePercent
//
//  Created by 霍然 on 3/10/23.
//

import SwiftUI

struct NewTrackerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AimTracker.order, ascending: true)],
        predicate: NSPredicate(format: "is_completed == %@", NSNumber(value: false)),
        animation: .default)
    private var items: FetchedResults<AimTracker>
    
    @State private var title = ""
    @State private var total_progress = ""
    @State private var default_step = ""
    @State private var notify = false
    @State private var challenger = false
    @State private var limit_time = false
    @State private var end_date = Date()
    
    @State private var showTotalZeroWarning = false
    @State private var showStepZeroWarning = false
    @State private var showStepExceedingWarning = false
    
    @State private var showAdvancedSettings = false
    // TODO: (later) I want to __str__ __int__ __str__
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("My New Aim", text: $title)
                    // TODO: add default focus
                    // Default focus method: https://developer.apple.com/forums/thread/681962
                }
                
                Section(header: Text("Total Progress")) {
                    TextField("100", text: $total_progress)
                        .keyboardType(.numberPad)
                    if showTotalZeroWarning {
                        Text("Total Progress must be greater than 0")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section(header: Text("Default Step")) {
                    TextField("1", text: $default_step)
                        .keyboardType(.numberPad)
                    if showStepZeroWarning {
                        Text("Default Step must be greater than 0")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    if showStepExceedingWarning {
                        Text("Default Step must be less than Total Progress")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                DisclosureGroup("Advanced Settings", isExpanded: $showAdvancedSettings) {
                    Toggle(isOn: $notify) {
                        Text("Notify Me")
                    }
                    // TODO: Notify time ...
                    
                    Toggle(isOn: $challenger) {
                        Text("Challenger Mode")
                    }
                    
                    if challenger {
                        Text("You will no longer be able to change any settings of the aim after you begin.")
                            .foregroundColor(.blue)
                    }
                    
                    Toggle(isOn: $limit_time) {
                        Text("Limit Time Aim")
                    }
                    
                    if limit_time {
                        DatePicker(selection: $end_date, in: Date.now..., displayedComponents: .date) {
                            Text("End by")
                        }
                    }
                }
                .onChange(of: total_progress, perform: { _ in
                    showTotalZeroWarning = false
                    showStepExceedingWarning = false
                })
                .onChange(of: default_step, perform: { _ in
                    showStepZeroWarning = false
                    showStepExceedingWarning = false
                })
            }
            .navigationTitle("New Aim Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if (!validateNewTracker()) {
                            return;
                        }
                        addTracker(withAttributes: [
                            "title": (title == "") ? "My New Aim" : title,
                            "total_progress": total_progress,
                            "default_step": default_step,
                            "start_date": Date()
                            // TODO: add more attributes
                        ], to: viewContext, items: items)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func validateNewTracker() -> Bool {
        var hasError = false
        let totalProgressValue = Int(total_progress) ?? 100
        let defaultStepValue = Int(default_step) ?? 1
        
        if totalProgressValue <= 0 {
            showTotalZeroWarning = true
            hasError = true
        }
        
        if defaultStepValue <= 0 {
            showStepZeroWarning = true
            hasError = true
        }
        
        if defaultStepValue > totalProgressValue {
            showStepExceedingWarning = true
            hasError = true
        }
        
        return !hasError
    }
}

struct NewTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        NewTrackerView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
