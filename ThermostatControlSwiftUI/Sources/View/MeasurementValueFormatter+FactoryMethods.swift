import UIKit

extension MeasurementValueFormatter {

    static func humidityValueFormatter() -> MeasurementValueFormatter {
        return MeasurementValueFormatter(suffix: "%")
    }

    static func celsiusValueFormatter() -> MeasurementValueFormatter {
        return MeasurementValueFormatter(suffix: "",
                                         prefix: "",
                                         roundingThreshold: 0.5,
                                         minimumFractionDigits: 1,
                                         maximumFractionDigits: 1)
    }

    static func fahrenheitValueFormatter() -> MeasurementValueFormatter {
        return MeasurementValueFormatter(suffix: "",
                                         prefix: "",
                                         roundingThreshold: 1.0,
                                         minimumFractionDigits: 0,
                                         maximumFractionDigits: 0)
    }

}
