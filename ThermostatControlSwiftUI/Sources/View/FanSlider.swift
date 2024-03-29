//
//  FanSlider.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/22/24.
//

import SwiftUI

struct FanSlider: View {

    @Binding private(set) var isEnabled: Bool
    @Binding private(set) var value: CGFloat

    @State private var leftFunRotation: CGFloat = 0
    @State private var rightFunRotation: CGFloat = 0

    var body: some View {
        HStack(alignment: .center, spacing: 8, content: {
            Text("􁁌")
                .font(Stylesheet.FontFace.SFProRoundedSemiBold.font(12))
                .foregroundColor(.white.opacity(0.5))
                .rotationEffect(.degrees(leftFunRotation))
            Slider(value: $value, in: 0...1, onEditingChanged: { editing in
                if editing {
                    leftFunRotation = 0
                    rightFunRotation = 0
                } else {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        rightFunRotation = roundedRotation(valueDegrees: rightFunRotation, reversed: false)
                        leftFunRotation = roundedRotation(valueDegrees: leftFunRotation, reversed: true)
                    }
                }
            })
            .tint(isEnabled ? Stylesheet.Color.coldMode : .white.opacity(0.5))
            Text("􁁌")
                .font(Stylesheet.FontFace.SFProRoundedSemiBold.font(16))
                .foregroundColor(.white.opacity(0.5))
                .rotationEffect(.degrees(rightFunRotation))
        })
        .opacity(isEnabled ? 1.0 : 0.2)
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(.white.opacity(0.08))
        .cornerRadius(12)
        .disabled(!isEnabled)
        .onChange(of: value) { oldValue, newValue in
           onSliderValueChange(oldValue: oldValue, newValue: newValue)
        }
    }

}

// MARK: - Private

private extension FanSlider {

    private func onSliderValueChange(oldValue: CGFloat, newValue: CGFloat) {
        if oldValue > newValue {
            leftFunRotation -= 6
            withAnimation(.easeInOut(duration: 0.3)) {
                rightFunRotation = roundedRotation(valueDegrees: rightFunRotation,
                                                   toDegrees: 90,
                                                   reversed: false)
            }
        } else {
            rightFunRotation += 6
            withAnimation(.easeInOut(duration: 0.3)) {
                leftFunRotation = roundedRotation(valueDegrees: leftFunRotation,
                                                  toDegrees: 90,
                                                  reversed: true)
            }
        }
    }

    private func roundedRotation(valueDegrees: CGFloat,
                                 stepDegrees: CGFloat = 90,
                                 toDegrees: CGFloat = 180,
                                 reversed: Bool = false) -> CGFloat {
        let remainder = abs(valueDegrees).truncatingRemainder(dividingBy: stepDegrees)
        if remainder > CGFloat.ulpOfOne {
            let addedValue = toDegrees - remainder
            return valueDegrees + (reversed ? -addedValue : addedValue)
        } else {
            return valueDegrees
        }
    }

}

#Preview {
    struct Preview: View {

        @State private var isEnabled: Bool = false
        @State private var value: CGFloat = 0

        var body: some View {
            VStack {
                Toggle("On/Of", isOn: $isEnabled)
                FanSlider(isEnabled: $isEnabled, value: $value)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
        }
    }
    return Preview()
}
