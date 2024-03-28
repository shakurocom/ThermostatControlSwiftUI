//
//  CGPoint+Distance.swift
//

import CoreGraphics

extension CGPoint {

    /// Finds the square distance to a point.
    /// - parameter point: specified point.
    func squaredDistance(to point: CGPoint) -> CGFloat {
        let xDistance = x - point.x
        let yDistance = y - point.y
        return xDistance * xDistance + yDistance * yDistance
    }

    /// Finds the distance to a point.
    /// - parameter point: specified point.
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(squaredDistance(to: point))
    }

    /// Multiplies a point by the specified amount.
    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
}
