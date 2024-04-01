//
//  ThermostatContentView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 2/5/24.
//

import SwiftUI

enum ThermostatMode {
    case auto
    case cooling
    case heating

    var color: Color {
        switch self {
        case .auto:
            Stylesheet.Color.autoMode
        case .cooling:
            Stylesheet.Color.coldMode
        case .heating:
            Stylesheet.Color.hotMode
        }
    }
}

struct ThermostatContentView: View {

    @State private var mode: ThermostatMode = .auto
    @State private var isEnabled = false
    @State private var roomName = "Living Room"
    @State private var fanSpeed: CGFloat = 0.5
    @State private var currentValue = MeasurementValueFormatter.Value(raw: 70, formatted: 70, string: "70")
    @State private var drumViewConfiguration = DrumViewModel.Configuration(maxValue: 99, minValue: 45, valueFormatter: MeasurementValueFormatter.fahrenheitValueFormatter())

    @State private var autoModeButtonState: GlowingButton.ControlState = [.selected]
    @State private var heatingModeButtonState: GlowingButton.ControlState = []
    @State private var coolingModeButtonState: GlowingButton.ControlState = []

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
                         configuration: drumViewConfiguration,
                         isEnabled: isEnabled,
                         contentViewBuilder: makeDrumImage)

            }

            Spacer(minLength: 72)

            FanSlider(value: $fanSpeed, isEnabled: isEnabled, color: mode.color)
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .containerRelativeFrame([.horizontal, .vertical])
        .background(.black)
        .onChange(of: mode, initial: true, onModeChanged)
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
                    .tint(mode.color)
                    .onChange(of: isEnabled) { _, _ in
                        if isEnabled {
                            autoModeButtonState.insert(.enabled)
                            heatingModeButtonState.insert(.enabled)
                            coolingModeButtonState.insert(.enabled)
                        } else {
                            autoModeButtonState.remove(.enabled)
                            heatingModeButtonState.remove(.enabled)
                            coolingModeButtonState.remove(.enabled)
                        }
                    }
            })
            .padding(.horizontal, 20)
            .frame(height: 64)
            .background(.white.opacity(0.08))
            .cornerRadius(12)
        })
    }

    @ViewBuilder private func makeLabels() -> some View {
        VStack(alignment: .leading, spacing: -12, content: {
            Text("°F")
                .font(Stylesheet.FontFace.SFProRoundedBold.font(20))
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(currentValue.string)
                .lineLimit(0)
                .font(Stylesheet.FontFace.SFProRoundedBold.font(104))
                .minimumScaleFactor(0.6)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(height: 124, alignment: .leading)
            Text("􁃛 56%")
                .font(Stylesheet.FontFace.SFProRoundedMedium.font(16))
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(isEnabled ? 1.0 : 0.2)
    }

    @ViewBuilder private func makeBottomButtons() -> some View {
        VStack(spacing: 4, content: {
            GlowingButton(image: Image(systemName: "a.circle"),
                          title: "Auto",
                          selectedColor: ThermostatMode.auto.color,
                          cornerRadius: 16,
                          animateImageOnSelectionChanged: false,
                          state: $autoModeButtonState,
                          action: {
                mode = .auto
            })
            .frame(width: 164, height: 80)
            .font(Stylesheet.FontFace.SFProRoundedBold.font(20))
            HStack(spacing: 4) {
                GlowingButton(image: Image(systemName: "snowflake"),
                              title: nil,
                              selectedColor: ThermostatMode.cooling.color,
                              cornerRadius: 16,
                              animateImageOnSelectionChanged: true,
                              state: $coolingModeButtonState,
                              action: {
                    mode = .cooling
                })
                .frame(width: 80, height: 80)
                GlowingButton(image: Image(systemName: "sun.max"),
                              title: nil,
                              selectedColor: ThermostatMode.heating.color,
                              cornerRadius: 16,
                              animateImageOnSelectionChanged: true,
                              state: $heatingModeButtonState,
                              action: {
                    mode = .heating
                })
                .frame(width: 80, height: 80)
            }
        })
    }

    @ViewBuilder private func makeDrumImage(_ size: CGSize, _ rotationAngle: Angle) -> some View {
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
            .opacity(isEnabled ? 1.0 : 0.8)
    }
}

// MARK: Helpers

private extension ThermostatContentView {

    func onModeChanged(_ oldValue: ThermostatMode, _ newValue: ThermostatMode) {
        switch newValue {
        case .auto:
            autoModeButtonState.insert(.selected)
            heatingModeButtonState.remove(.selected)
            coolingModeButtonState.remove(.selected)
        case .cooling:
            autoModeButtonState.remove(.selected)
            heatingModeButtonState.remove(.selected)
            coolingModeButtonState.insert(.selected)
        case .heating:
            autoModeButtonState.remove(.selected)
            heatingModeButtonState.insert(.selected)
            coolingModeButtonState.remove(.selected)
        }
    }

}

#Preview {
    ThermostatContentView()
}
