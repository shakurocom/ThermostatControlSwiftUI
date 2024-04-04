//
//  DrumViewModel.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/28/24.
//

import SwiftUI

public final class DrumViewModel: ObservableObject {

    public struct Configuration: Equatable {
        public let maxValue: CGFloat
        public let minValue: CGFloat
        public let maxAngleRad: CGFloat
        public let angleToValueFactor: CGFloat
        public let valueFormatter: MeasurementValueFormatter

        public init(maxValue: CGFloat,
                    minValue: CGFloat,
                    maxAngle: Angle,
                    valueFormatter: MeasurementValueFormatter) {
            self.maxValue = maxValue
            self.minValue = minValue
            self.maxAngleRad = maxAngle.radians
            self.angleToValueFactor = (maxValue - minValue) / (maxAngleRad * 2)
            self.valueFormatter = valueFormatter
        }
    }

    private enum Constant {
        static let minimumDecelerationVelocity: CGFloat = (.pi / 180) * 20
        static let decelerationFactor: CGFloat = 0.91
        static let maxValue: CGFloat = 1
        static let minValue: CGFloat = 0
    }

    public private(set) var formattedValue: MeasurementValueFormatter.Value = .zero
    @Published public private(set) var rotation: Angle = .radians(0)

    private var rotationRad: CGFloat = 0 {
        didSet {
            rotation = .radians(rotationRad)
        }
    }

    private var configuration = Configuration(maxValue: Constant.maxValue,
                                              minValue: Constant.minValue,
                                              maxAngle: .radians(.pi),
                                              valueFormatter: MeasurementValueFormatter())

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

    public init(rawValue: CGFloat,
                configuration: Configuration) {
        self.configuration = configuration
        setValue(rawValue, updateRotation: true)
    }

    deinit {
        decelerationBehaviour.stop()
    }

    public func setValue(_ newValue: CGFloat, updateRotation: Bool) {
        let newFormattedValue = configuration.valueFormatter.formatted(rawValue: min(max(newValue, configuration.minValue), configuration.maxValue))
        if formattedValue != newFormattedValue {
            formattedValue = newFormattedValue
        }
        if updateRotation {
            let newRotationRad = configuration.maxAngleRad - (newFormattedValue.raw - configuration.minValue) / configuration.angleToValueFactor
            if rotationRad != newRotationRad {
                rotationRad = newRotationRad
            }
        }
    }

    public func setConfiguration(_ config: Configuration) {
        configuration = config
        setValue(formattedValue.raw, updateRotation: true)
    }

    public func stopDeceleration() {
        decelerationBehaviour.stop()
    }

    public func decelerate(_ velocity: CGFloat, clockwise: Bool) -> Bool {
        decelerationBehaviour.stop()
        guard velocity >= Constant.minimumDecelerationVelocity else {
            return false
        }
        decelerationBehaviour.decelerate(velocity: velocity,
                                         onUpdate: { [weak self] value in
            let offset = Angle.radians(clockwise ? value : -value)
            self?.update(offset: offset)
        }, onComplete: { [weak self] in
            self?.updateToMaxRotationIfNeededAnimated()
        })
        return true
    }

    public func rotationGesture(touchAreaSize: CGSize) -> AnyGesture<RotationGestureRecognizer.Value> {
        rotationGestureRecognizer.touchAreaSize = touchAreaSize
        return rotationGesture
    }

}

// MARK: - Private

private extension DrumViewModel {

    private func makeRotationGesture() -> AnyGesture<RotationGestureRecognizer.Value> {
        let gesture = rotationGestureRecognizer
            .gesture()
            .onChanged({ [weak self] value in
                guard let actualSelf = self else {
                    return
                }
                switch value.state {
                case .inactive:
                    break
                case .started:
                    actualSelf.stopDeceleration()
                case .changed:
                    actualSelf.update(offset: value.angleOffset)
                }
            })
            .onEnded({ [weak self] value in
                guard let actualSelf = self else {
                    return
                }
                if !actualSelf.decelerate(value.angularVelocity, clockwise: value.clockwise) {
                    actualSelf.updateToMaxRotationIfNeededAnimated()
                }
            })
        return AnyGesture<RotationGestureRecognizer.Value>(gesture)
    }

    private func update(offset: Angle) {
        let offsetRad = offset.radians
        let maxAngleRad = configuration.maxAngleRad + .pi * 0.006 // + 1 degree to capture the value
        let newRotationRad = rotationRad + offsetRad
        let absNewRotationRad = abs(newRotationRad)

        if absNewRotationRad > maxAngleRad, absNewRotationRad > abs(rotationRad) {
            let maximumRotationRad = maxAngleRad + .pi * 0.2
            let slowdownFactor = maximumRotationRad / absNewRotationRad - 1
            rotationRad += offsetRad * slowdownFactor
        } else {
            rotationRad = newRotationRad
        }

        let valueOffset = offsetRad * configuration.angleToValueFactor
        setValue(formattedValue.raw - valueOffset, updateRotation: false)
    }

    private func updateToMaxRotationIfNeededAnimated() {
        guard rotationGestureRecognizer.state == .inactive, abs(rotationRad) > configuration.maxAngleRad else {
            return
        }
        withAnimation(.easeInOut(duration: 0.4)) {
            rotationRad = rotationRad > 0 ? configuration.maxAngleRad : -configuration.maxAngleRad
        }
    }

}
