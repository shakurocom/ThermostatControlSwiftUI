//
//  DrumView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/22/24.
//

import SwiftUI

public struct DrumView: View {

    @StateObject private var model: DrumViewModel

    let configuration: DrumViewModel.Configuration

    init(value: Binding<MeasurementValueFormatter.Value>,
         configuration: DrumViewModel.Configuration) {
        self.configuration = configuration
        _model = StateObject(wrappedValue: DrumViewModel(value: value,
                                                         configuration: configuration))
    }

    public var body: some View {
        // Main geometry container
        GeometryReader(content: { geometry in

            // Gesture view
            let size = CGSize(width: geometry.size.height, height: geometry.size.height)
            ZStack(content: {
                makeDrumImage(size: size, rotationAngle: model.rotation)
            })
            .frame(width: size.height,
                   height: size.height,
                   alignment: .leading)
           // .background(.blue)
           // .border(.green)
            .gesture(model.rotationGesture(touchAreaSize: size))
        })
        // .background(.yellow)
        .clipped()
        .onChange(of: configuration, { _, newValue in
            model.setConfiguration(newValue)
        })
        .onDisappear(perform: {
            model.stopDeceleration()
        })
    }

}

private extension DrumView {

    @ViewBuilder private func makeDrumImage(size: CGSize, rotationAngle: Angle) -> some View {
        Image("drum")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .mask {
                Image("drumMask")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .rotationEffect(-rotationAngle, anchor: .center)
            }
            .frame(width: size.height,
                   height: size.height,
                   alignment: .leading)
            // .background(.red)
            .clipped()
            .rotationEffect(rotationAngle, anchor: .center)
    }

}

#Preview {
    @State var value: MeasurementValueFormatter.Value = .zero
    return DrumView(value: $value, configuration: DrumViewModel.Configuration(maxValue: 99, minValue: 45, valueFormatter: MeasurementValueFormatter.fahrenheitValueFormatter())).background(.black)
}
