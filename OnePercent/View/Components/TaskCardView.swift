//
//  TaskCardView.swift
//  OnePercent
//
//  Created by 霍然 on 8/19/23.
//

import SwiftUI

struct TaskCardView: View {
    let tracker: AimTracker
    private let cardColor = Color("color.secondary")
    private let cardColorLight = Color("color.secondary.light")
    @Binding private var percentageCompleted: Double
    
    init(tracker: AimTracker, percentageCompleted: Binding<Double>) {
        self.tracker = tracker
        // TODO: set color?
        
        _percentageCompleted = percentageCompleted
    }
    
    var body: some View {
        if (percentageCompleted != 1.0) {
            // Current trackers
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardColor)
                    .padding(8)
                    .opacity(0.5)
                    .frame(width:UIScreen.main.bounds.width)
                    .shadow(color: Color("color.absolute").opacity(0.2), radius: 5)
                
                HStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(cardColor)
                        .padding(8)
                        .frame(width:UIScreen.main.bounds.width * percentageCompleted, alignment: .leading)
                    Spacer()
                }
            }
        } else {
            // Completed trackers
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [cardColor, cardColorLight]), startPoint: .leading, endPoint: .trailing))
                .padding(8)
                .frame(width:UIScreen.main.bounds.width)
                .shadow(color: Color("color.absolute").opacity(0.2), radius: 5)
        }
    }
}
