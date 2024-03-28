//
//  DrumView.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/22/24.
//

import SwiftUI

private final class DrumViewModel: ObservableObject {

    private enum Constant {
        public static let minimumDecelerationVelocity: CGFloat = (.pi / 180) * 4
        public static let decelerationFactor: CGFloat = 0.92
    }

    @Published private(set) var rotation: Angle = .radians(0)

    private let rotationGestureRecognizer = RotationGestureRecognizer()
    private lazy var rotationGesture: AnyGesture<RotationGestureRecognizer.Value> = {
        return makeRotationGesture()
    }()

    private var decelerationBehaviour: DecelerationBehaviour = {
        let deceleration = DecelerationBehaviour()
        deceleration.minVelocity = Constant.minimumDecelerationVelocity
        deceleration.decelerationFactor = Constant.decelerationFactor
        return deceleration
    }()

    deinit {
        decelerationBehaviour.stop()
    }

    func stopDeceleration() {
        decelerationBehaviour.stop()
    }

    func decelerate(_ velocity: CGFloat, clockwise: Bool) -> Bool {
        decelerationBehaviour.stop()
        guard velocity >= Constant.minimumDecelerationVelocity else {
            return false
        }
        decelerationBehaviour.decelerate(velocity: velocity,
                                         onUpdate: { [weak self] value in
            self?.rotation += Angle.radians(clockwise ? value : -value)
        }, onComplete: {

        })
        /* decelerationBehaviour.decelerate(velocity: velocity,
         update: { [weak self] (distance) in self?.update(by: distance, clockwise: clockwise) },
         completion: { [weak self] in self?.feedbackGenerator = nil })*/
        return true
    }

    func rotationGesture(touchAreaSize: CGSize) -> AnyGesture<RotationGestureRecognizer.Value> {
        rotationGestureRecognizer.touchAreaSize = touchAreaSize
        return rotationGesture
    }

    private func makeRotationGesture() -> AnyGesture<RotationGestureRecognizer.Value> {
        let gesture = rotationGestureRecognizer
            .gesture()
            .onChanged({ [weak self] value in
                guard let actualSelf = self else {
                    return
                }
                switch value.state {
                case .inactive, .started:
                    return
                case .changed:
                    actualSelf.rotation += value.angleOffset
                }
            })
            .onEnded({ [weak self] value in
                guard let actualSelf = self else {
                    return
                }
                if !actualSelf.decelerate(value.angularVelocity, clockwise: value.clockwise) {
                    //feedbackGenerator = nil
                }
            })
        return AnyGesture<RotationGestureRecognizer.Value>(gesture)
    }
}

public struct DrumView: View {

    public enum Constant {
        public static let maxValue: CGFloat = 1
        public static let minValue: CGFloat = 0
        public static let fullСycleAngle: CGFloat = .pi

    }

    @StateObject private var model = DrumViewModel()

    public var body: some View {
        // Main geometry container
        GeometryReader(content: { geometry in

            // Gesture view
            let size = CGSize(width: geometry.size.height, height: geometry.size.height)
            ZStack(content: {
                makeDrumImage(size: size, rotationAngle: model.rotation)
            })
            .frame(width: size.height,
                   height: size.height,
                   alignment: .leading)
            .background(.blue)
            .border(.green)
            .gesture(model.rotationGesture(touchAreaSize: size))
        })
        .background(.yellow)
        .clipped()
        .onDisappear(perform: {
            model.stopDeceleration()
        })
    }

}

private extension DrumView {

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
