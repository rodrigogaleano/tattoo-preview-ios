import Foundation

/// Presets de tom de pele pela escala Fitzpatrick, aplicados como tint sobre a textura neutra.
nonisolated enum SkinTone: Int, CaseIterable, Codable {
    case typeI = 1
    case typeII
    case typeIII
    case typeIV
    case typeV
    case typeVI

    var rgb: SIMD3<Float> {
        switch self {
        case .typeI: [0.96, 0.84, 0.76]
        case .typeII: [0.92, 0.75, 0.63]
        case .typeIII: [0.83, 0.64, 0.50]
        case .typeIV: [0.69, 0.48, 0.34]
        case .typeV: [0.49, 0.31, 0.20]
        case .typeVI: [0.29, 0.18, 0.12]
        }
    }
}
