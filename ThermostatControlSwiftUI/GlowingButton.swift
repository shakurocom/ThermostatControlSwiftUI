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
        HStack {
            Spacer().frame(width: 24)

            if state.contains([.selected, .enabled]) {
                makeContent()
            } else {
                makeContent().opacity(0.2)
            }

            Spacer().frame(width: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.1), value: state)
    }

    @ViewBuilder private func makeContent() -> some View {
        HStack {
            if let actualTitle = title {
                Text(actualTitle)
                    .foregroundColor(currentColor)
                    .shadow(color: currentColor.opacity(0.5), radius: 16, x: 0, y: 0)
            }

            if image != nil, !(title?.isEmpty ?? true) {
                Spacer(minLength: 16)
            }

            if let actualImage = image {
                actualImage.font(.system(size: 24, weight: .regular))
                    .foregroundColor(currentColor)
                    .shadow(color: currentColor.opacity(0.5), radius: 16, x: 0, y: 0)
            }
        }
    }

}

#Preview {
    VStack(alignment: .center, content: {
        GlowingButton(image: Image(systemName: "snowflake"),
                      title: "Auto",
                      selectedColor: Color(UIColor(hex: "#30D158") ?? .green),
                      cornerRadius: 16).frame(width: 164, height: 80)
        GlowingButton(image: Image(systemName: "snowflake"),
                      title: nil,
                      selectedColor: Color(UIColor(hex: "#30D158") ?? .green),
                      cornerRadius: 16).frame(width: 80, height: 80)
    })
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}
