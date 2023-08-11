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
    
//    @State private var notify = false
    @State private var limit_time = false
    @State private var planned_end_date = Date()
    @State private var timer_only = false
    @State private var min_time_index = 0
    @State private var challenger = false
    
    enum FocusField: Hashable {
        case field
    }
    @FocusState private var focusedField: FocusField?
    
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
                        .focused($focusedField, equals: .field)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.focusedField = .field
                               }
                        }
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
//                    Toggle(isOn: $notify) {
//                        Text("Notify Me Everyday")
//                    }
                    // TODO: (later) Notify time ...
                    
                    Toggle(isOn: $limit_time) {
                        Text("Limit Time Aim")
                    }
                    
                    if limit_time {
                        DatePicker(selection: $planned_end_date, in: Date.now..., displayedComponents: .date) {
                            Text("End by")
                        }
                    }
                    
                    Toggle(isOn: $timer_only) {
                        Text("Increment by Timer Only")
                    }
                    
                    if timer_only {
                        Text("You will only be able to increment the progress via the timer.")
                            .foregroundColor(.blue)

                        Picker("Select Minimum Time", selection: $min_time_index) {
                            ForEach(0..<minTimeOptions.count, id: \.self) { index in
                                Text(minTimeOptions[index])
                            }
                        }
                    }
                    
                    
                    Toggle(isOn: $challenger) {
                        Text("Challenger Mode")
                    }
                    
                    if challenger {
                        Text("You will no longer be able to change any settings of the aim after you begin.")
                            .foregroundColor(.blue)
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
            .animation(.easeOut)
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
                            "total_progress": Int64(total_progress) ?? 100,
                            "default_step": Int64(default_step) ?? 1,
                            "start_date": Date(),
                            "limit_time": limit_time,
                            "planned_end_date": planned_end_date,
                            "timer_only": timer_only,
                            "min_time_index": min_time_index,
                            "challenger": challenger
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
