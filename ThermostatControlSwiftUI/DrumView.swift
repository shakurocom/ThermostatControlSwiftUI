//
//  DrumView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/22/24.
//

import SwiftUI

struct DrumView: View {

    @StateObject private var rotationGestureRecognizer = RotationGestureRecognizer()
    @State private(set) var rotation: Angle = .radians(0)

    var body: some View {
        // Main geometry container
        GeometryReader(content: { geometry in

            // Gesture view
            let size = CGSize(width: geometry.size.height, height: geometry.size.height)
            ZStack(content: {
                makeDrumImage(size: size, rotationAngle: rotation)
            })
            .frame(width: size.height,
                   height: size.height,
                   alignment: .leading)
            .background(.blue)
            .border(.green)
            .gesture(rotationGesture(touchAreaSize: size))
        })
        .background(.yellow)
        .clipped()
    }

}

private extension DrumView {

    private func rotationGesture(touchAreaSize: CGSize) -> AnyGesture<RotationGestureRecognizer.Value> {
        let gesture = rotationGestureRecognizer
            .gesture(touchAreaSize: touchAreaSize)
            .onChanged({ value in
                switch value.state {
                case .inactive, .started:
                    return
                case .changed:
                    rotation += value.angleOffset
                }
            })
            .onEnded({ value in
                //print("x ended: \(value)")
            })
        return AnyGesture<RotationGestureRecognizer.Value>(gesture)
    }

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
            .background(.red)
            .clipped()
            .rotationEffect(rotationAngle, anchor: .center)
    }

}

#Preview {
    DrumView().background(.black)
}

/*
 
 */
