//
//  DecelerationBehaviour.swift
//
//  Created by Vlad
//

import UIKit

public final class DecelerationBehaviour {

    /// Indicates the minimum speed before stopping.
    public var minVelocity: CGFloat = 0

    /// Determines the deceleration factor. 0...1. 1 - will never stop.
    public var decelerationFactor: CGFloat = 0

    private var timer: CADisplayLink?
    private var currentVelocity: CGFloat = 0

    private var completion: (() -> Void)?
    private var update: ((_ distance: CGFloat) -> Void)?

    ///  Used to slow down animation
    /// - Parameters:
    ///  - velocity: Initial velocity.
    ///  - distance: Block to be called for decelaration distance.
    ///  - completion: Block to be called  when minVelocity > velocity.
    public func decelerate(velocity: CGFloat,
                           update: ((_ distance: CGFloat) -> Void)?,
                           completion: (() -> Void)? = nil) {
        stop()
        currentVelocity = velocity
        self.completion = completion
        self.update = update
        startTimer()
    }

    /// Used to stop animation.
    public func stop() {
        update = nil
        stopTimer()
        currentVelocity = 0
        completion?()
        completion = nil
    }

    // MARK: - Private

    private func startTimer() {
        stopTimer()
        let newTimer = CADisplayLink(target: self, selector: #selector(timerTick))
        newTimer.add(to: RunLoop.main, forMode: .common)
        timer = newTimer
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func timerTick(_ sender: CADisplayLink) {
        currentVelocity *= decelerationFactor
        guard currentVelocity >= minVelocity else {
            stop()
            return
        }
        let distance = currentVelocity * CGFloat(sender.duration)
        update?(distance)
    }

}
