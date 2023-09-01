//
//  CongratesPageView.swift
//  OnePercent
//
//  Created by 霍然 on 7/16/23.
//

import SwiftUI

class CongratsPageController: ObservableObject {
    @Published var isShowingCongratsPage = false
    var completedAimTitle = ""
}

struct CongratsPageView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var congratsPageController: CongratsPageController
        
    var body: some View {
        VStack {
            Text("Congratulations!")
                .font(.largeTitle)
                .padding()
            Text("You have reached your aim: \(congratsPageController.completedAimTitle)!")
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}

struct CongratsPageView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = CongratsPageController()
        controller.isShowingCongratsPage = true
        controller.completedAimTitle = "Sample Aim"
        
        return CongratsPageView().environmentObject(controller)
    }
}
