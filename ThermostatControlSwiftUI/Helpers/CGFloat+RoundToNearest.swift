import UIKit

public extension CGFloat {

    /// Returns this value rounded to an integral value using “schoolbook rounding" with threshold.
    func roundToNearest(_ threshold: CGFloat) -> CGFloat {
        let denominator = 1.0 / threshold
        return (self * denominator).rounded() / denominator
    }

}
