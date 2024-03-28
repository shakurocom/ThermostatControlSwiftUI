import UIKit

extension DefaultMeasurementValueTransformer {

    static func humidityValueTransformer() -> MeasurementValueTransformer {
        return DefaultMeasurementValueTransformer(suffix: "%")
    }

    static func celsiusValueTransformer() -> MeasurementValueTransformer {
        return DefaultMeasurementValueTransformer(suffix: "",
                                                  prefix: "",
                                                  roundingThreshold: 0.5,
                                                  minimumFractionDigits: 1,
                                                  maximumFractionDigits: 1)
    }

    static func fahrenheitValueTransformer() -> MeasurementValueTransformer {
        return DefaultMeasurementValueTransformer(suffix: "",
                                                  prefix: "",
                                                  roundingThreshold: 1.0,
                                                  minimumFractionDigits: 0,
                                                  maximumFractionDigits: 0)
    }

}
