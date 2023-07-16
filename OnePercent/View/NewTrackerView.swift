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
    
    @State private var title = ""
    @State private var total_progress = ""
    @State private var default_step = ""
    @State private var notify = false
    @State private var challenger = false
    @State private var limit_time = false
    @State private var end_date = Date()
    
    @State private var show_advanced_settings = false
    // TODO: (later) I want to __str__ __int__ __str__
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("My New Aim", text: $title)
                    // TODO: add default focus
                    // Default focus method: https://developer.apple.com/forums/thread/681962
                    
                    // TODO: same name check
                    // add a check function?
                }
                
                Section(header: Text("Total Progress")) {
                    TextField("100", text: $total_progress)
                        .keyboardType(.numberPad)
                    // TODO: num check
                }
                
                Section(header: Text("Default Step")) {
                    TextField("1", text: $default_step)
                        .keyboardType(.numberPad)
                    // TODO: less than header check
                }
                
                DisclosureGroup("Advanced Settings", isExpanded: $show_advanced_settings) {
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
                        addTracker(withAttributes: [
                            "title": (title == "") ? "My New Aim" : title,
                            "total_progress": Int64(total_progress) ?? 100,
                            "default_step": Int64(default_step) ?? 1,
                            "start_date": Date()
                            // TODO: add more attributes
                        ], to: viewContext)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct NewTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        NewTrackerView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
