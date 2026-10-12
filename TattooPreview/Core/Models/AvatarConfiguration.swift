import Foundation

nonisolated struct AvatarConfiguration: Equatable, Codable {
    static let weightRange: ClosedRange<Float> = -1...1

    /// −1 magro, 1 corpulento.
    var weight: Float = 0
    var skinTone: SkinTone = .typeIII
}
