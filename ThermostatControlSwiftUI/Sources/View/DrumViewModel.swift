//
//  DrumViewModel.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/28/24.
//

import SwiftUI

final class DrumViewModel: ObservableObject {

    private enum Constant {
        static let minimumDecelerationVelocity: CGFloat = (.pi / 180) * 4
        static let decelerationFactor: CGFloat = 0.92
        static let maxValue: CGFloat = 1
        static let minValue: CGFloat = 0
        static let fullСycleAngle: CGFloat = .pi
    }

    @Binding private(set) var value: MeasurementValue
    @Published private(set) var rotation: Angle = .radians(0)

    private(set) var maxValue: CGFloat = Constant.maxValue
    private(set) var minValue: CGFloat = Constant.minValue
    private(set) var angleToValueFactor: CGFloat = (Constant.maxValue - Constant.minValue) / Constant.fullСycleAngle
    private(set) var valueTransformer: MeasurementValueTransformer = DefaultMeasurementValueTransformer.fahrenheitValueTransformer()

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
    ///  - valueTransformer: Actual value tranformer
    ///  - maxValue: Max value
    ///  - minValue: Min value
    ///  - fullСycleAngle: Angle from which changes are counted. Default - .pi
    init(value: Binding<MeasurementValue>,
         valueTransformer: MeasurementValueTransformer,
         maxValue: CGFloat,
         minValue: CGFloat) {
        _value = value
        self.valueTransformer = valueTransformer
        self.maxValue = maxValue
        self.minValue = minValue
        angleToValueFactor = (maxValue - minValue) / Constant.fullСycleAngle
        setValue(value.wrappedValue.raw)
    }

    deinit {
        decelerationBehaviour.stop()
    }

    /// Sets a value in the range from minimum to maximum
    /// - parameter newValue:
    public func setValue(_ newValue: CGFloat) {
        let newValue = valueTransformer.transformed(rawValue: min(max(newValue, minValue), maxValue))
        if value != newValue {
            value = newValue
        }
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
        let oldValue = value.transformed
        rotation += offset
        setValue(value.raw + valueOffset)
        if abs(oldValue - value.transformed) > CGFloat.ulpOfOne {
            feedbackGenerator?.selectionChanged()
            feedbackGenerator?.prepare()
        }
    }
}
