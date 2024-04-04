//
//  ThermostatContentView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 2/5/24.
//

import SwiftUI
import Lottie

enum ThermostatMode {
    case auto
    case cooling
    case heating

    var color: Color {
        switch self {
        case .auto:
                .autoMode
        case .cooling:
                .coolingMode
        case .heating:
                .heatingMode
        }
    }
}

struct ThermostatContentView: View {

    private final class DrumViewValue: DrumValueObservable {
        @Published var formattedValue: MeasurementValueFormatter.Value
        var rotation: Angle

        init(formattedValue: MeasurementValueFormatter.Value) {
            self.formattedValue = formattedValue
            self.rotation = .degrees(0)
        }
    }

    @State private var mode: ThermostatMode = .auto
    @State private var isEnabled = false

    @State private var lottieViewState: LottieViewState = .stoppedHidden
    @State private var showColoredDrum: Bool = false

    @State private var roomName = "Living Room"
    @State private var fanSpeed: CGFloat = 0.5

    @StateObject private var currentValue: DrumViewValue
    @State private var drumViewConfiguration: DrumViewModel.Configuration

    @State private var autoModeButtonState: GlowingButton.ControlState = [.selected]
    @State private var heatingModeButtonState: GlowingButton.ControlState = []
    @State private var coolingModeButtonState: GlowingButton.ControlState = []

    init() {
        let valueFormatter = MeasurementValueFormatter.fahrenheitValueFormatter()
        _drumViewConfiguration = State(wrappedValue: DrumViewModel.Configuration(maxValue: 99,
                                                                                 minValue: 45,
                                                                                 maxAngle: .radians(.pi * 0.5),
                                                                                 valueFormatter: valueFormatter))
        _currentValue = StateObject(wrappedValue: DrumViewValue(formattedValue: valueFormatter.formatted(rawValue: 70)))
    }

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

                DrumView(value: currentValue,
                         configuration: drumViewConfiguration,
                         isEnabled: isEnabled,
                         contentViewBuilder: makeDrumImage)
                .allowsHitTesting((lottieViewState.isHidden && (lottieViewState.playbackMode == .paused)))

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
                    .onChange(of: isEnabled, onIsEnabledChanged)
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
            Text(currentValue.formattedValue.string)
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
            GlowingButton(state: $autoModeButtonState, image: Image(systemName: "a.circle"),
                          title: "Auto",
                          selectedColor: ThermostatMode.auto.color,
                          cornerRadius: 16,
                          animateImageOnSelectionChanged: false,
                          action: {
                mode = .auto
            })
            .frame(width: 164, height: 80)
            .font(Stylesheet.FontFace.SFProRoundedBold.font(20))
            HStack(spacing: 4) {
                GlowingButton(state: $coolingModeButtonState,
                              image: Image(systemName: "snowflake"),
                              title: nil,
                              selectedColor: ThermostatMode.cooling.color,
                              cornerRadius: 16,
                              animateImageOnSelectionChanged: true,
                              action: {
                    mode = .cooling
                })
                .frame(width: 80, height: 80)
                GlowingButton(state: $heatingModeButtonState,
                              image: Image(systemName: "sun.max"),
                              title: nil,
                              selectedColor: ThermostatMode.heating.color,
                              cornerRadius: 16,
                              animateImageOnSelectionChanged: true,
                              action: {
                    mode = .heating
                })
                .frame(width: 80, height: 80)
            }
        })
    }

    @ViewBuilder private func makeDrumImage(_ size: CGSize, _ rotationAngle: Angle) -> some View {
        makeDrumImage(name: "drum", size: size, rotationAngle: rotationAngle).opacity(showColoredDrum ? 0.0 : 1.0)
        makeDrumImage(name: "coloredDrum", size: size, rotationAngle: rotationAngle).opacity(showColoredDrum ? 1.0 : 0.0)
        if !lottieViewState.isHidden {
            LottieView(animation: .named("ThermostatLottie"))
                .resizable()
                .playbackMode(lottieViewState.playbackMode)
                .animationDidFinish({ completed in
                    guard completed else {
                        return
                    }
                    if isEnabled {
                        let oldState = lottieViewState
                        setColoredDrumHiddenAnimated(false, completion: {
                            guard oldState == lottieViewState else {
                                return
                            }
                            lottieViewState = .stoppedHidden
                        })
                    } else {
                        lottieViewState = .stoppedHidden
                    }
                })
                .clipped()
                .rotationEffect(rotationAngle, anchor: .center)
        }
    }

    @ViewBuilder private func makeDrumImage(name: String, size: CGSize, rotationAngle: Angle) -> some View {
        Image(name)
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
            .clipped()
            .rotationEffect(rotationAngle, anchor: .center)
            .opacity(isEnabled ? 1.0 : 0.8)
    }

}

// MARK: Helpers

private extension ThermostatContentView {

    func setColoredDrumHiddenAnimated(_ hidden: Bool, completion: (() -> Void)? = nil) {
        withAnimation(.linear(duration: 0.2), completionCriteria: .logicallyComplete, {
            showColoredDrum = !hidden
        }, completion: {
            completion?()
        })
    }

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

    func onIsEnabledChanged(_ oldValue: Bool, _ newValue: Bool) {
        let currentRotationProgress = (drumViewConfiguration.maxAngleRad - currentValue.rotation.radians) / (drumViewConfiguration.maxAngleRad * 2) // from 0-1
        let visibleAnimationProgress = 0.415 // depends on lottie.json values
        let startAnimationProgress = 0.02 // depends on lottie.json values
        let fromProgress = visibleAnimationProgress * currentRotationProgress + startAnimationProgress
        let toProgress = fromProgress + visibleAnimationProgress
        if isEnabled {
            lottieViewState = LottieViewState.playing(fromProgress: lottieViewState.isHidden ? fromProgress : nil,
                                                      toProgress: toProgress)
            autoModeButtonState.insert(.enabled)
            heatingModeButtonState.insert(.enabled)
            coolingModeButtonState.insert(.enabled)
        } else {
            setColoredDrumHiddenAnimated(true)
            lottieViewState = LottieViewState.playingReversed(fromProgress: lottieViewState.isHidden ? toProgress : nil,
                                                              toProgress: fromProgress)
            autoModeButtonState.remove(.enabled)
            heatingModeButtonState.remove(.enabled)
            coolingModeButtonState.remove(.enabled)
        }
    }

}

// MARK: LottieViewState

private extension ThermostatContentView {

    struct LottieViewState: Equatable {

        let playbackMode: LottiePlaybackMode
        let isHidden: Bool

        static func playing(fromProgress: AnimationProgressTime?,
                            toProgress: AnimationProgressTime) -> LottieViewState {
            LottieViewState(playbackMode: .playing(.fromProgress(fromProgress, toProgress: toProgress, loopMode: .playOnce)),
                            isHidden: false)
        }
        static func playingReversed(fromProgress: AnimationProgressTime?,
                                    toProgress: AnimationProgressTime) -> LottieViewState {
            LottieViewState(playbackMode: .playing(.fromProgress(fromProgress, toProgress: toProgress, loopMode: .playOnce)),
                            isHidden: false)
        }

        static var stoppedHidden: LottieViewState {
            LottieViewState(playbackMode: .paused, isHidden: true)
        }

    }

}

// MARK: - Preview

#Preview {
    ThermostatContentView()
}
