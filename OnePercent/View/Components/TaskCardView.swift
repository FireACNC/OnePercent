//
//  TaskCardView.swift
//  OnePercent
//
//  Created by 霍然 on 8/19/23.
//

import SwiftUI

struct TaskCardView: View {
    var tracker: AimTracker
    
    var body: some View {
        Rectangle()
            .fill(Color.white)
//            .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
    }
}



struct TaskCardView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCardView(tracker: AimTracker.sampleForPreview())
    }
}
