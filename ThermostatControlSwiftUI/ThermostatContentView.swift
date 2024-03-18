//
//  ThermostatContentView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 2/5/24.
//

import SwiftUI

struct ThermostatContentView: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                GlowingButton(image: Image(systemName: "snowflake"),
                              title: nil,
                              selectedColor: Color(UIColor(hex: "#30D158") ?? .green),
                              cornerRadius: 16,
                              animateImageOnSelectionChanged: true)
                .frame(width: 80, height: 80)
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .background(Color.black)
            VStack {
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .background(Color.black)
        } .background(Color.yellow)
    }
}

#Preview {
    ThermostatContentView()
}
