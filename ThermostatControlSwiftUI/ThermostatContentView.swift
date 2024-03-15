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
                              title: "Auto",
                              selectedColor: .red,
                              cornerRadius: 16)
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
