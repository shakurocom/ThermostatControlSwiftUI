//
//  GlowingButton.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/7/24.
//

import SwiftUI
import Shakuro_CommonTypes

public struct GlowingButton: View {

    public struct ControlState: OptionSet {

        public let rawValue: Int32
        public static let selected = ControlState(rawValue: 1 << 0)
        public static let enabled = ControlState(rawValue: 1 << 1)

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

    }

    @Binding public private(set) var state: ControlState

    public let image: Image?
    public let title: String?
    public let selectedColor: Color
    public let cornerRadius: CGFloat
    public let animateImageOnSelectionChanged: Bool

    public let action: () -> Void

    private var currentBGColor: Color {
        return state.contains([.selected, .enabled]) ? selectedColor.opacity(0.14) : .white.opacity(0.08)
    }

    private var currentColor: Color {
        return state.contains([.selected, .enabled]) ? selectedColor : .white
    }

    private var shadowRadius: CGFloat {
        return state.contains([.selected, .enabled]) ? 16 : 0
    }

    private var contentOpacity: CGFloat {
        if state.contains(.enabled) {
            return state.contains(.selected) ? 1.0 : 0.4
        } else {
            return 0.2
        }
    }

    public var body: some View {
        Button(action: {
            guard state.contains(.enabled), !state.contains(.selected) else {
                return
            }
            state.insert(.selected)
            action()
        }, label: {
            makeBody()
        })
        .background(currentBGColor)
        .cornerRadius(cornerRadius)
        .disabled(!state.contains(.enabled))
        .sensoryFeedback(.impact, trigger: state.contains(.selected))
    }

}

// MARK: - Private

// MARK: View Builders

private extension GlowingButton {

    @ViewBuilder private func makeBody() -> some View {
        ZStack {
            makeContent().opacity(contentOpacity)
            makeSelectionIndicator()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.1), value: state)
    }

    @ViewBuilder private func makeContent() -> some View {
        HStack {
            Spacer().frame(width: 24)

            if let actualTitle = title {
                Text(actualTitle)
                    .foregroundColor(currentColor)
                    .shadow(color: currentColor.opacity(0.5), radius: shadowRadius, x: 0, y: 0)
            }

            if image != nil, !(title?.isEmpty ?? true) {
                Spacer(minLength: 16)
            }

            if animateImageOnSelectionChanged {
                makeImage()
                    .rotationEffect(.degrees(state.contains([.selected]) ? 0 : -180))
                    .animation(.easeInOut(duration: 0.5), value: state)
            } else {
                makeImage()
            }

            Spacer().frame(width: 24)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder private func makeImage() -> some View {
        if let actualImage = image {
            actualImage.font(.system(size: 24, weight: .bold))
                .foregroundColor(currentColor)
                .animation(nil, value: state)
                .shadow(color: currentColor.opacity(0.5), radius: shadowRadius, x: 0, y: 0)
        }
    }

    @ViewBuilder private func makeSelectionIndicator() -> some View {
        HStack(content: {
            Spacer(minLength: 20)
            Color(selectedColor)
                .frame(maxWidth: state.contains([.selected, .enabled]) ? .infinity : 0)
                .frame(height: 3)
                .clipShape(
                    .rect(
                        topLeadingRadius: 8,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 8
                    )
                )
                .shadow(color: selectedColor.opacity(0.5), radius: shadowRadius, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.4), value: state)
            Spacer(minLength: 20)
        }).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

}

#Preview {

    struct Preview: View {

        @State var button1: GlowingButton.ControlState = [.enabled, .selected]
        @State var button2: GlowingButton.ControlState = .enabled

        var body: some View {
            VStack(alignment: .center, content: {
                GlowingButton(state: $button1,
                              image: Image(systemName: "snowflake"),
                              title: "Auto",
                              selectedColor: Color(UIColor(hex: "#30D158") ?? .green),
                              cornerRadius: 16,
                              animateImageOnSelectionChanged: true, action: {}).frame(width: 164, height: 80)
                GlowingButton(state: $button2,
                              image: Image(systemName: "snowflake"),
                              title: nil,
                              selectedColor: Color(UIColor(hex: "#30D158") ?? .green),
                              cornerRadius: 16,
                              animateImageOnSelectionChanged: false, action: {}).frame(width: 80, height: 80)
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
        }
    }

    return Preview()

}
