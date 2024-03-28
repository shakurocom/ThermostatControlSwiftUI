//
//  CircleDragGesture.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/26/24.
//

import SwiftUI

final class RotationGestureRecognizer {

    struct Value: Equatable {

        static var zero: Value {
            Value(state: .inactive,
                  angleRadians: 0,
                  previousAngleRadians: 0,
                  angularVelocity: 0,
                  clockwise: true,
                  touchAreaSize: .zero)
        }

        let state: RotationGestureRecognizer.State
        let angle: Angle
        let previousAngle: Angle
        let angleOffset: Angle
        let angularVelocity: CGFloat
        let clockwise: Bool

        let touchAreaSize: CGSize

        init(state: RotationGestureRecognizer.State,
             angleRadians: CGFloat,
             previousAngleRadians: CGFloat,
             angularVelocity: CGFloat,
             clockwise: Bool,
             touchAreaSize: CGSize) {
            self.state = state
            self.angle = Angle.radians(angleRadians)
            self.previousAngle = Angle.radians(previousAngleRadians)
            let offset = abs(abs(previousAngleRadians) - abs(angleRadians))
            self.angleOffset = Angle.radians(clockwise ? offset : -offset)
            self.angularVelocity = angularVelocity
            self.clockwise = clockwise
            self.touchAreaSize = touchAreaSize
        }

    }

    enum State {
        case inactive
        case started
        case changed
    }
    
    var touchAreaSize: CGSize = .zero

    private(set) var state: State = .inactive

    private var dragGesture: AnyGesture<Value>!
    private var previousAngle: CGFloat = 0

    init() {
        self.dragGesture = AnyGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged({ [weak self] _ in
                    self?.state.next()
                })
                .onEnded({ [weak self] _ in
                    self?.state = .inactive
                })
                .map({ [weak self] value in
                    guard let actualSelf = self else {
                        return Value.zero
                    }
                    return actualSelf.mapValue(value: value)
                })
        )
    }

    func gesture() -> AnyGesture<Value> {
        return dragGesture
    }

    func gesture(touchAreaSize: CGSize) -> AnyGesture<Value> {
        self.touchAreaSize = touchAreaSize
        return dragGesture
    }

}

// MARK: - Private

private extension RotationGestureRecognizer.State {

    mutating func next() {
        switch self {
        case .inactive:
            self = .started
        case .started:
            self = .changed
        case .changed:
            break
        }
    }

}

private extension RotationGestureRecognizer {

    func centerBasedTouchLocation(value: DragGesture.Value, areaSize: CGSize) -> CGPoint {
        return CGPoint(x: value.location.x - areaSize.width * 0.5, y: areaSize.height * 0.5 - value.location.y)
    }

    func angleBetweenXAxisForPoint(point: CGPoint) -> CGFloat {
        return atan2(point.y, point.x)
    }

    func mapValue(value: DragGesture.Value) -> RotationGestureRecognizer.Value {
        let touchLocation = centerBasedTouchLocation(value: value, areaSize: touchAreaSize)
        let angle = angleBetweenXAxisForPoint(point: touchLocation)
        let velocity = value.velocity
        let magnitude = sqrt((velocity.width * velocity.width) + (velocity.height * velocity.height)) // The Pythagorean Theorem
        let radius = touchLocation.distance(to: .zero)
        let angularVelocity = magnitude / radius // relationship between angular velocity and linear ω=v/r.
        if state != .changed {
            previousAngle = angle
        }

        let newValue = Value(state: state,
                             angleRadians: angle,
                             previousAngleRadians: previousAngle,
                             angularVelocity: angularVelocity,
                             clockwise: velocity.height < 0.0,
                             touchAreaSize: touchAreaSize)
        previousAngle = angle
        return newValue
    }

}
