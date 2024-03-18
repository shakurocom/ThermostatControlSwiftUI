//
//  GlowingButton.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/7/24.
//

import SwiftUI
import Shakuro_CommonTypes

struct GlowingButton: View {

    struct ControlState: OptionSet {
        let rawValue: Int32
        static let selected = ControlState(rawValue: 1 << 0)
        static let enabled = ControlState(rawValue: 1 << 1)
    }

    let image: Image?
    let title: String?
    let selectedColor: Color
    let cornerRadius: CGFloat
    let animateImageOnSelectionChanged: Bool

    @State private var state: ControlState = [.enabled]

    private var currentBGColor: Color {
        return state.contains([.selected, .enabled]) ? selectedColor.opacity(0.14) : .white.opacity(0.08)
    }

    private var currentColor: Color {
        return state.contains([.selected, .enabled]) ? selectedColor : .white
    }

    private var contentOpacity: CGFloat {
        return state.contains([.selected, .enabled]) ? 1.0 : 0.2
    }
    
    private var shadowRadius: CGFloat {
        return state.contains([.selected, .enabled]) ? 16 : 0
    }

    var body: some View {
        Button(action: {
            guard state.contains(.enabled) else {
                return
            }
            if state.contains(.selected) {
                state.remove(.selected)
            } else {
                state.insert(.selected)
            }
        }, label: {
            makeBody()
        })
        .background(currentBGColor)
        .cornerRadius(cornerRadius)
    }

    @ViewBuilder private func makeBody() -> some View {
        ZStack {
            makeContent().opacity(state.contains([.selected, .enabled]) ? 1.0 : 0.2)
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

            if let actualImage = image {
                actualImage.font(.system(size: 24, weight: .regular))
                    .foregroundColor(currentColor)
                    .animation(nil, value: state)
                    .shadow(color: currentColor.opacity(0.5), radius: shadowRadius, x: 0, y: 0)
                    .rotationEffect(.degrees(state.contains([.selected]) ? 0 : 180))
                    .animation(.easeInOut(duration: 0.5), value: state)
            }

            Spacer().frame(width: 24)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder private func makeSelectionIndicator() -> some View {
        HStack(content: {
            Spacer(minLength: 20)
            Color(selectedColor)
                .frame(width: state.contains([.selected]) ? .infinity : 0, height: 3)
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
    VStack(alignment: .center, content: {
        GlowingButton(image: Image(systemName: "snowflake"),
                      title: "Auto",
                      selectedColor: Color(UIColor(hex: "#30D158") ?? .green),
                      cornerRadius: 16,
                      animateImageOnSelectionChanged: true).frame(width: 164, height: 80)
        GlowingButton(image: Image(systemName: "snowflake"),
                      title: nil,
                      selectedColor: Color(UIColor(hex: "#30D158") ?? .green),
                      cornerRadius: 16,
                      animateImageOnSelectionChanged: false).frame(width: 80, height: 80)
    })
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}
