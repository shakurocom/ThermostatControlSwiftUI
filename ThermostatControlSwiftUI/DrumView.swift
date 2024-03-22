//
//  DrumView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/22/24.
//

import SwiftUI

struct DrumView: View {

    @State private(set) var rotation: CGFloat = 0

    var body: some View {
        Image("drum")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .mask {
                Image("drumMask")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .rotationEffect(.degrees(-rotation))
            }
            .rotationEffect(.degrees(rotation))
            .frame(minWidth: 0, alignment: .leading)
            .clipped()
    }
}

#Preview {
    DrumView().background(.black)
}
