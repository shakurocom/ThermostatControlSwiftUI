//
//  DrumView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/22/24.
//

import SwiftUI

public protocol DrumValueObservable: ObservableObject {
    var formattedValue: MeasurementValueFormatter.Value { get set }
    var rotation: Angle { get set }
}

public struct DrumView<ContentViewType: View, ValueType: DrumValueObservable>: View {

    private let isEnabled: Bool
    private let configuration: DrumViewModel.Configuration

    private var value: ValueType

    @StateObject private var model: DrumViewModel
    @ViewBuilder private let contentViewBuilder: (_ size: CGSize, _ rotationAngle: Angle) -> ContentViewType

    public init(value: ValueType,
                configuration: DrumViewModel.Configuration,
                isEnabled: Bool,
                @ViewBuilder contentViewBuilder: @escaping (_ size: CGSize, _ rotationAngle: Angle) -> ContentViewType) {
        self.configuration = configuration
        self.contentViewBuilder = contentViewBuilder
        self.isEnabled = isEnabled
        self.value = value
        _model = StateObject(wrappedValue: DrumViewModel(rawValue: value.formattedValue.raw,
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
        .sensoryFeedback(.selection, trigger: model.formattedValue, condition: { lhs, rhs in
            return abs(lhs.formatted - rhs.formatted) > .ulpOfOne
        })
        .onChange(of: configuration, { _, newValue in
            model.setConfiguration(newValue)
        })
        .onChange(of: model.rotation, initial: true, { _, newValue in
            value.rotation = newValue
        })
        .onChange(of: model.formattedValue, initial: true, { _, newValue in
            value.formattedValue = newValue
        })
        .onDisappear(perform: {
            model.stopDeceleration()
        })
    }

}

#Preview {
    struct Preview: View {

        final class Value: DrumValueObservable {
            @Published var formattedValue: MeasurementValueFormatter.Value
            @Published var rotation: Angle

            init(formattedValue: MeasurementValueFormatter.Value, rotation: Angle) {
                self.formattedValue = formattedValue
                self.rotation = rotation
            }
        }

        @StateObject var value: Value = Value(formattedValue: .zero, rotation: .degrees(0))
        @State var isEnabled: Bool = true

        var body: some View {
            DrumView(value: value,
                     configuration: DrumViewModel.Configuration(maxValue: 99, minValue: 45, maxAngle: .radians(.pi * 0.5), valueFormatter: MeasurementValueFormatter.fahrenheitValueFormatter()),
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
