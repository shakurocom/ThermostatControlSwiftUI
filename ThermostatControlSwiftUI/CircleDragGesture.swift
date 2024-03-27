//
//  CircleDragGesture.swift
//  ThermostatControlSwiftUI
//
//  Created by Vlad on 3/26/24.
//

import SwiftUI

final class CircleDragGesture: Gesture, ObservableObject {

    struct Value: Equatable {
        
        static let zero = Value(state: .inactive,
                                angleRadians: 0,
                                previousAngleRadians: 0,
                                angularVelocity: 0,
                                clockwise: true,
                                touchAreaSize: .zero)
        
        let state: CircleDragGesture.State
        let angle: Angle
        let previousAngle: Angle
        let angleOffset: Angle
        let angularVelocity: CGFloat
        let clockwise: Bool

        let touchAreaSize: CGSize
        
        init(state: CircleDragGesture.State,
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

    var touchAreaSize: CGSize

    private(set) var state: State = .inactive

    private var dragGesture: AnyGesture<Value>!

    private var previousAngle: CGFloat = 0

    init(touchAreaSize: CGSize) {
        self.touchAreaSize = touchAreaSize
        self.dragGesture = AnyGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged({ [weak self] _ in
                    self?.updateToNextState()
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

    public var body: AnyGesture<Value> {
        return dragGesture
    }

}

// MARK: - Private

private extension CircleDragGesture {

    func centerBasedTouchLocation(value: DragGesture.Value, areaSize: CGSize) -> CGPoint {
        return CGPoint(x: value.location.x - areaSize.width * 0.5, y: areaSize.height * 0.5 - value.location.y)
    }

    func angleBetweenXAsisForPoint(point: CGPoint) -> CGFloat {
        return atan2(point.y, point.x)
    }

    func mapValue(value: DragGesture.Value) -> CircleDragGesture.Value {
        let touchLocation = centerBasedTouchLocation(value: value, areaSize: touchAreaSize)
        let angle = angleBetweenXAsisForPoint(point: touchLocation)
        let velocity = value.velocity
        let magnitude = sqrt((velocity.width * velocity.width) + (velocity.height * velocity.height)) // The Pythagorean Theorem
        let radius = touchLocation.distance(to: .zero)
        let angularVelocity = magnitude / radius // relationship between angular velocity and linear ω=v/r.
        if state != .changed {
            previousAngle = angle
        }
        debugPrint(angularVelocity)
        let newValue = Value(state: state,
                             angleRadians: angle,
                             previousAngleRadians: previousAngle,
                             angularVelocity: angularVelocity,
                             clockwise: velocity.height < 0.0,
                             touchAreaSize: touchAreaSize)
        previousAngle = angle
        return newValue
    }

    func updateToNextState() {
        switch state {
        case .inactive:
            state = .started
        case .started:
            state = .changed
        case .changed:
            break
        }
    }

}
