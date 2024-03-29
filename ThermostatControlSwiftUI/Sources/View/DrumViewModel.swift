//
//  DrumViewModel.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/28/24.
//

import SwiftUI

final class DrumViewModel: ObservableObject {

    struct Configuration: Equatable {
        let maxValue: CGFloat
        let minValue: CGFloat
        let valueFormatter: MeasurementValueFormatter
    }

    private enum Constant {
        static let minimumDecelerationVelocity: CGFloat = (.pi / 180) * 4
        static let decelerationFactor: CGFloat = 0.92
        static let maxValue: CGFloat = 1
        static let minValue: CGFloat = 0
        static let fullСycleAngle: CGFloat = .pi
    }

    @Binding private(set) var value: MeasurementValueFormatter.Value
    @Published private(set) var rotation: Angle = .radians(0)

    private(set) var configuration = Configuration(maxValue: Constant.maxValue,
                                                   minValue: Constant.minValue,
                                                   valueFormatter: MeasurementValueFormatter())

    private(set) var angleToValueFactor: CGFloat = (Constant.maxValue - Constant.minValue) / Constant.fullСycleAngle

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

    private var feedbackGenerator: UISelectionFeedbackGenerator?

    /// - Parameters:
    ///  - value: Value binding
    ///  - fullСycleAngle: Angle from which changes are counted. Default - .pi
    init(value: Binding<MeasurementValueFormatter.Value>,
         configuration: Configuration) {
        _value = value
        setConfiguration(configuration)
    }

    deinit {
        decelerationBehaviour.stop()
    }

    /// Sets a value in the range from minimum to maximum
    /// - parameter newValue:
    public func setValue(_ newValue: CGFloat) {
        let newValue = configuration.valueFormatter.formatted(rawValue: min(max(newValue, configuration.minValue), configuration.maxValue))
        debugPrint(newValue)
        if value != newValue {
            value = newValue
        }
    }

    public func setConfiguration(_ config: Configuration) {
        configuration = config
        angleToValueFactor = (config.maxValue - config.minValue) / Constant.fullСycleAngle
        setValue(value.raw)
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
            let offset = Angle.radians(clockwise ? value : -value)
            self?.update(offset: offset)
        }, onComplete: { [weak self] in
            self?.feedbackGenerator = nil
        })
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
                case .inactive:
                    break
                case .started:
                    actualSelf.stopDeceleration()
                    actualSelf.feedbackGenerator = UISelectionFeedbackGenerator()
                    actualSelf.feedbackGenerator?.prepare()
                case .changed:
                    actualSelf.update(offset: value.angleOffset)
                }
            })
            .onEnded({ [weak self] value in
                guard let actualSelf = self else {
                    return
                }
                if !actualSelf.decelerate(value.angularVelocity, clockwise: value.clockwise) {
                    actualSelf.feedbackGenerator = nil
                }
            })
        return AnyGesture<RotationGestureRecognizer.Value>(gesture)
    }

    private func update(offset: Angle) {
        let radians = offset.radians
        let valueOffset = radians * angleToValueFactor
        let oldValue = value.formatted
        rotation += offset
        setValue(value.raw + valueOffset)
        if abs(oldValue - value.formatted) > CGFloat.ulpOfOne {
            feedbackGenerator?.selectionChanged()
            feedbackGenerator?.prepare()
        }
    }
}
