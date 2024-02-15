//
//  ContentView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 2/5/24.
//

import SwiftUI

struct ThermostatContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .edgesIgnoringSafeArea(.all)
            Text("Hello, world!")
                .edgesIgnoringSafeArea(.all)
            Spacer()
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .background(Color.green)
    }
}

#Preview {
    ThermostatContentView()
}
