//
//  DrumView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/22/24.
//

import SwiftUI

public struct DrumView: View {

    @StateObject private var model: DrumViewModel

    init(value: Binding<MeasurementValue>,
         maxUnitValue: CGFloat,
         minUnitValue: CGFloat,
         valueTransformer: MeasurementValueTransformer) {
        _model = StateObject(wrappedValue: DrumViewModel(value: value,
                                                         valueTransformer: valueTransformer,
                                                         maxValue: maxUnitValue,
                                                         minValue: minUnitValue))
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
    @State var value: MeasurementValue = .zero
    return DrumView(value: $value, maxUnitValue: 99, minUnitValue: 45, valueTransformer: DefaultMeasurementValueTransformer.fahrenheitValueTransformer()).background(.black)
}
