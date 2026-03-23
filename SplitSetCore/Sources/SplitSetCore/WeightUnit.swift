import Foundation

public enum WeightUnit: String, Codable, CaseIterable, Sendable {
    case kg
    case lb

    public static var current: WeightUnit {
        Locale.current.measurementSystem == .metric ? .kg : .lb
    }

    public var label: String {
        switch self {
        case .kg: "kg"
        case .lb: "lb"
        }
    }

    /// Convert a value stored in kg to this unit for display
    public func fromKg(_ kg: Double) -> Double {
        switch self {
        case .kg: kg
        case .lb: kg * 2.20462
        }
    }

    /// Convert a value in this unit back to kg for storage
    public func toKg(_ value: Double) -> Double {
        switch self {
        case .kg: value
        case .lb: value / 2.20462
        }
    }

    /// Format a weight stored in kg for display in this unit
    public func format(_ kg: Double) -> String {
        let value = fromKg(kg).rounded()
        return "\(String(format: "%.0f", value)) \(label)"
    }

    /// The step size for the Digital Crown / stepper in this unit
    public var step: Double { 1.0 }

    /// Default starting weight for the picker in this unit
    public var defaultWeight: Double {
        switch self {
        case .kg: 20.0
        case .lb: 45.0
        }
    }

    /// Max weight for the Digital Crown in this unit
    public var maxWeight: Double {
        switch self {
        case .kg: 500.0
        case .lb: 1100.0
        }
    }
}
