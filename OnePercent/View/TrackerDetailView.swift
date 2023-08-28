//
//  TrackerDetailView.swift
//  OnePercent
//
//  Created by 霍然 on 7/2/23.
//

import SwiftUI

struct TrackerDetailView: View {
    let tracker: AimTracker
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var congratsPageController: CongratsPageController
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AimTracker.order, ascending: true)],
        predicate: NSPredicate(format: "is_completed == %@", NSNumber(value: false)),
        animation: .default)
    private var items: FetchedResults<AimTracker>

    @State private var currentProgress: Int
    @State private var isEditing = false
    @State private var percentageDone: Int
    @State private var fractionDone: CGFloat
    @State private var waveStart: CGFloat = 0

    
    init(tracker: AimTracker) {
        self.tracker = tracker
        _currentProgress = State(initialValue: Int(tracker.curr_progress))
        _percentageDone = State(initialValue: Int((tracker.curr_progress * 200 + tracker.total_progress) / (2 * tracker.total_progress)))
        _fractionDone = State(initialValue: CGFloat(Double(tracker.curr_progress) / Double(tracker.total_progress)))
    }
    
    var body: some View {
        let startDate = tracker.start_date ?? Date(timeIntervalSince1970: 0)
        let endDate = tracker.start_date ?? Date(timeIntervalSince1970: 0)

        let general_detail = """
            Title: \(tracker.title ?? "")
            Current Progress: \(currentProgress)
            Total Progress: \(tracker.total_progress)
            Started on: \(itemDateFormatter.string(from: startDate))
            Time Spent: \(timeFormatted(Int(tracker.time_spent)))
            Limit Time Aim: \(tracker.limit_time ? "Yes" : "No")
            Increment by Timer Only: \(tracker.timer_only ? "Yes" : "No")
            Minimum Time Selection: \(minTimeOptions[Int(tracker.min_time_index)])
            Challenger Mode: \(tracker.challenger ? "Enabled" : "Disabled")
            
            - Debug use
            Order: \(tracker.order)
            """
        
        let completed_detail = """
            Completed on: \(itemDateFormatter.string(from: endDate))
            """
        
        let detailText = tracker.is_completed ? general_detail + "\n" + completed_detail : general_detail
        
        let wheelText = !tracker.is_completed ? "\(percentageDone)%" : "Done!"
        let wheelTextSize: CGFloat = !tracker.is_completed ? 120 : 100
                
        NavigationView {
            ZStack {
                Color("color.background").ignoresSafeArea()
                
                VStack {
                    HStack {
                        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "arrowshape.turn.up.backward.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Text(tracker.title ?? "")
                        .font(Font.custom("CooperHewitt-Heavy", size: 30))
                        .padding()
                        .baselineOffset(-5)
                    
                    // https://www.youtube.com/watch?v=pTLfio2F2oQ
                    GeometryReader { proxy in
                        let size = proxy.size
                        ZStack {
                            Image (systemName: "circle.fill")
                                .resizable ()
                                .renderingMode (.template)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color("color.secondary.light").opacity(0.3))
                                .scaleEffect(x: 0.8, y: 0.8)
                            
                            Wave(progress: fractionDone, waveHeight: 0.05, offset: waveStart)
                                .fill(Color("color.secondary"))
                                .overlay {
                                    Text(wheelText)
                                        .font(Font.custom("CooperHewitt-Heavy", size: wheelTextSize))
                                        .padding()
                                        .baselineOffset(-30)
                                        .foregroundColor(Color("color.primary"))
                                }
                                .mask {
                                    Image (systemName: "circle.fill")
                                        .resizable ()
                                        .aspectRatio(contentMode: .fit)
                                        .scaleEffect(x: 0.8, y: 0.8)
                                        .padding(20)
                                }
                            
                        }
                        .frame(width: size.width, height: size.height, alignment: .center)
                        .onAppear {
                            withAnimation(.linear(duration: 2).repeatForever(autoreverses:false)) {
                                // Manually adjust wave size
                                waveStart = (size.width - 30)
                            }
                        }
                    }
                    .frame(height: 400)
                    
                    Text("\(currentProgress)/\(tracker.total_progress)")
                        .font(Font.custom("CooperHewitt-Heavy", size: 30))
                        .baselineOffset(-5)

                    
                    //            Text(detail)
                    
                    if !tracker.is_completed {
                        if !tracker.timer_only {
                            Button(action: {
                                incrementProgress()
                                if tracker.curr_progress >= tracker.total_progress {
                                    congratsPageController.completedAimTitle = tracker.title!
                                    congratsPageController.isShowingCongratsPage = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        completeTracker(tracker: tracker, from: viewContext, items: items)
                                        self.presentationMode.wrappedValue.dismiss()
                                        // TODO: (late) maybe add a guide for checking complete?
                                    }
                                }
                            }) {
                                Image(systemName: "plus")
                                    .padding()
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(width: 250, height: 40)
                            }
                            .buttonStyle(.borderedProminent)

                        } else {
                            Text("You can only increment the progress via the timer.")
                                .font(Font.custom("CooperHewitt-Heavy", size: 20))
                                .padding()
                                .baselineOffset(-5)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // The Spacer is used for locating the button
                    Spacer()
                    
                    // There's a bug if add toolbar to the navigation link, it may sometimes show duplicated toolbar and thus have a glitch.
                    if !tracker.challenger {
                        Button(action: {
                            isEditing = true
                        }) {
                            Text("Edit")
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $isEditing) {
                EditOrCreateTrackerView(trackerToEdit: tracker)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func incrementProgress() {
        tracker.curr_progress += tracker.default_step
        currentProgress = Int(tracker.curr_progress)
        percentageDone = Int((tracker.curr_progress * 200 + tracker.total_progress) / (2 * tracker.total_progress))
        fractionDone = CGFloat(Double(tracker.curr_progress) / Double(tracker.total_progress))
        save(context: viewContext)

    }
}

// Enable Swipe Back Action
// https://stackoverflow.com/questions/59234958/swiftui-navigationbarbackbuttonhidden-swipe-back-gesture

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

    // To make it works also with ScrollView
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

//struct TrackerDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackerDetailView(tracker: AimTracker.sampleForPreview())
//    }
//}

struct TrackerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

