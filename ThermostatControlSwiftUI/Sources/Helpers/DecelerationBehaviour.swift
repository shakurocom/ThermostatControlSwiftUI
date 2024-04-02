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

    private var onComplete: (() -> Void)?
    private var onUpdate: ((_ distance: CGFloat) -> Void)?

    ///  Used to slow down animation
    /// - Parameters:
    ///  - velocity: Initial velocity.
    ///  - onUpdate: Block to be called for decelaration distance.
    ///  - onComplete: Block to be called  when minVelocity > velocity.
    public func decelerate(velocity: CGFloat,
                           onUpdate: ((_ distance: CGFloat) -> Void)?,
                           onComplete: (() -> Void)? = nil) {
        stop()
        currentVelocity = velocity
        self.onComplete = onComplete
        self.onUpdate = onUpdate
        startTimer()
    }

    /// Used to stop animation.
    public func stop() {
        onUpdate = nil
        stopTimer()
        currentVelocity = 0
        onComplete?()
        onComplete = nil
    }

}

// MARK: - Private

private extension DecelerationBehaviour {

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
        onUpdate?(distance)
    }

}
