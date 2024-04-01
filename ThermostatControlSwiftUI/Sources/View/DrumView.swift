//
//  DrumView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/22/24.
//

import SwiftUI

public struct DrumView<ContentViewType: View>: View {

    let isEnabled: Bool
    let configuration: DrumViewModel.Configuration

    @StateObject private var model: DrumViewModel
    @ViewBuilder private let contentViewBuilder: (_ size: CGSize, _ rotationAngle: Angle) -> ContentViewType

    init(value: Binding<MeasurementValueFormatter.Value>,
         configuration: DrumViewModel.Configuration,
         isEnabled: Bool,
         @ViewBuilder contentViewBuilder: @escaping (_ size: CGSize, _ rotationAngle: Angle) -> ContentViewType) {
        self.configuration = configuration
        self.contentViewBuilder = contentViewBuilder
        self.isEnabled = isEnabled
        _model = StateObject(wrappedValue: DrumViewModel(value: value,
                                                         configuration: configuration))
    }

    public var body: some View {
        // Main geometry container
        GeometryReader(content: { geometry in

            // Gesture view
            let size = CGSize(width: geometry.size.height, height: geometry.size.height)
            ZStack(content: {
                contentViewBuilder(size, model.rotation)
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
        .disabled(!isEnabled)
        .onChange(of: configuration, { _, newValue in
            model.setConfiguration(newValue)
        })
        .onDisappear(perform: {
            model.stopDeceleration()
        })
    }

}

#Preview {
    struct Preview: View {

        @State var value: MeasurementValueFormatter.Value = .zero
        @State var isEnabled: Bool = true

        var body: some View {
            DrumView(value: $value,
                     configuration: DrumViewModel.Configuration(maxValue: 99, minValue: 45, valueFormatter: MeasurementValueFormatter.fahrenheitValueFormatter()),
                     isEnabled: isEnabled,
                     contentViewBuilder: { size, rotationAngle in
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
            }).background(.black)
        }
    }
    return Preview()
}
