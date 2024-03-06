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
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .background(Color.green)
            VStack {
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
            .background(Color.red)
        } .background(Color.yellow)
    }
}

#Preview {
    ThermostatContentView()
}
