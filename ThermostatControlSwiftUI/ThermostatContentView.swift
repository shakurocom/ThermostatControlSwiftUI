//
//  ThermostatContentView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 2/5/24.
//

import SwiftUI

struct ThermostatContentView: View {

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack {
                    // Bottom buttons
                   Spacer()
                    VStack(spacing: 4, content: {
                        GlowingButton(image: Image(systemName: "a.circle"),
                                      title: "Auto",
                                      selectedColor: Stylesheet.Color.autoMode,
                                      cornerRadius: 16,
                                      animateImageOnSelectionChanged: false)
                        .frame(width: 164, height: 80)
                        .font(Stylesheet.FontFace.SFProRoundedRegular.font(20))
                        HStack(spacing: 4) {
                            GlowingButton(image: Image(systemName: "snowflake"),
                                          title: nil,
                                          selectedColor: Stylesheet.Color.coldMode,
                                          cornerRadius: 16,
                                          animateImageOnSelectionChanged: true)
                            .frame(width: 80, height: 80)
                            GlowingButton(image: Image(systemName: "sun.max"),
                                          title: nil,
                                          selectedColor: Stylesheet.Color.hotMode,
                                          cornerRadius: 16,
                                          animateImageOnSelectionChanged: true)
                            .frame(width: 80, height: 80)
                        }
                    })
                    .background(Color.black)
                }
                .frame(maxWidth: 164, maxHeight: .infinity)
                .background(Color.red)

                VStack {
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.green)
            }

            ZStack {
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(.black)
    }

}

#Preview {
    ThermostatContentView()
}
