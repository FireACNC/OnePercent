//
//  AppIcon.swift
//  OnePercent
//
//  Created by 霍然 on 8/31/23.
//

import SwiftUI

struct AppIcon: View {
    static let appIconSize: CGFloat = 512

    var body: some View {
        ZStack {
            Color.black
            
            Text("%")
                .font(Font.custom("CooperHewitt-Heavy", size: 360))
                .baselineOffset(-100)
                .padding()
                .shadow(color: .purple, radius: 130, x: 0, y: 0)
            
            Text("%")
                .font(Font.custom("CooperHewitt-Heavy", size: 360))
                .baselineOffset(-100)
                .padding()
                .shadow(color: .black, radius: 15, x: 0, y: 0)
                
        }
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.red, Color.yellow,  Color.blue, Color.purple, Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .mask(Text("%")
                .font(Font.custom("CooperHewitt-Heavy", size: 360))
                .baselineOffset(-100)
                .padding()
            )
        )
    }
}


struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        AppIcon()
            .previewLayout(.fixed(width: AppIcon.appIconSize, height: AppIcon.appIconSize))
    }
}
