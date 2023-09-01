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
        ZStack {
            RadialGradient(gradient: Gradient(colors: [
                Color("color.secondary.light"),
                Color("color.background")]), center: .center, startRadius: 0, endRadius: 500).ignoresSafeArea()

            VStack {
                Text("Congratulations🎉")
                    .font(Font.custom("CooperHewitt-Heavy", size: 40))
                    .baselineOffset(-5)
                    .padding()
                    .foregroundColor(Color("color.primary"))
                
                Text("You have reached your aim:\n \(congratsPageController.completedAimTitle)!")
                    .font(Font.custom("CooperHewitt-Medium", size: 20))
                    .baselineOffset(-5)
                    .multilineTextAlignment(.center)
//                    .padding()
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .offset(y: 50)
                .padding()
                .font(Font.custom("CooperHewitt-Heavy", size: 20))
                .baselineOffset(-5)
                .foregroundColor(Color("color.secondary"))
            }
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
