//
//  ThermostatContentView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 2/5/24.
//

import SwiftUI

struct ThermostatContentView: View {

    @State private var isEnabled = true
    @State private var roomName = "Living Room"
    @State private var fanSpeed: CGFloat = 0.5
    @State private var currentValue = MeasurementValue(raw: 70, transformed: 70, string: "70")

    @State private var valueTransformer = DefaultMeasurementValueTransformer.fahrenheitValueTransformer()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {

                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 30)

                    // Controls
                    makeControls()

                    Spacer(minLength: 8)

                    // Labels
                    makeLabels()
                        .background(Color.black)

                    Spacer().frame(height: 46)

                    // Bottom buttons
                    makeBottomButtons()
                        .background(Color.black)
                }
                .frame(width: 164)
                .background(Color.black)

                DrumView(value: $currentValue,
                         maxUnitValue: 99,
                         minUnitValue: 45,
                         valueTransformer: valueTransformer)

            }

            Spacer(minLength: 72)

            FanSlider(value: $fanSpeed)
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .containerRelativeFrame([.horizontal, .vertical])
        .background(.black)
    }

}

// MARK: - Private

// MARK: View Builders

private extension ThermostatContentView {

    @ViewBuilder private func makeControls() -> some View {
        VStack(alignment: .leading, spacing: 4, content: {
            HStack(alignment: .center) {
                Menu(content: {
                    Button("Living Room") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            roomName = "Living Room"
                        }
                    }
                    Button("Living Room 2") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            roomName = "Living Room 2"
                        }
                    }
                    Button("Dining room") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            roomName = "Dining Room"
                        }
                    }
                }, label: {
                    HStack(content: {
                        Text(roomName)
                            .minimumScaleFactor(0.8)
                            .font(Stylesheet.FontFace.SFProRoundedBold.font(16))
                            .foregroundColor(.white)
                        Spacer()
                        Text("􀆈")
                            .font(Stylesheet.FontFace.SFProRoundedBold.font(14))
                            .foregroundColor(.white.opacity(0.5))
                    }).frame(maxHeight: .infinity)
                }).frame(maxHeight: .infinity)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(.white.opacity(0.08))
            .cornerRadius(12)

            HStack(content: {
                Toggle("On/Of", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(Stylesheet.Color.coldMode)
            })
            .padding(.horizontal, 20)
            .frame(height: 64)
            .background(.white.opacity(0.08))
            .cornerRadius(12)
        })
    }

    @ViewBuilder private func makeLabels() -> some View {
        VStack(spacing: -12, content: {
            Text("°F")
                .font(Stylesheet.FontFace.SFProRoundedBold.font(20))
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(currentValue.string)
                .lineLimit(0)
                .font(Stylesheet.FontFace.SFProRoundedBold.font(104))
                .minimumScaleFactor(0.8)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("􁃛 56%")
                .font(Stylesheet.FontFace.SFProRoundedMedium.font(16))
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
        })
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private func makeBottomButtons() -> some View {
        VStack(spacing: 4, content: {
            GlowingButton(image: Image(systemName: "a.circle"),
                          title: "Auto",
                          selectedColor: Stylesheet.Color.autoMode,
                          cornerRadius: 16,
                          animateImageOnSelectionChanged: false)
            .frame(width: 164, height: 80)
            .font(Stylesheet.FontFace.SFProRoundedBold.font(20))
            HStack(spacing: 4) {
                GlowingButton(image: Image(systemName: "snowflake"),
                              title: nil,
                              selectedColor: Stylesheet.Color.coldMode,
                              cornerRadius: 16,
                              animateImageOnSelectionChanged: true)
                .frame(width: 80, height: 80)
                GlowingButton(image: Image(systemName: "sun.max"),
                              title: nil,
                              selectedColor: Stylesheet.Color.hotMode,
                              cornerRadius: 16,
                              animateImageOnSelectionChanged: true)
                .frame(width: 80, height: 80)
            }
        })
    }

}

#Preview {
    ThermostatContentView()
}
