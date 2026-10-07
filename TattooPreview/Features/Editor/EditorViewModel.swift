import Foundation

nonisolated enum AvatarLoadState: Equatable {
    case loading
    case loaded
    case failed
}

@Observable
final class EditorViewModel {
    static let defaultTattooWidth: Float = 0.08
    static let defaultTattooOpacity: Float = 0.9

    private(set) var avatarState: AvatarLoadState = .loading
    private(set) var placement: TattooPlacement?
    var skinTone: SkinTone = .typeIII
    /// −1 (magro) a 1 (corpulento).
    var bodyWeight: Float = 0

    func avatarDidLoad() {
        avatarState = .loaded
    }

    func avatarDidFail() {
        avatarState = .failed
    }

    /// Posiciona a tatuagem no UV tocado, com largura padrão em metros convertida pela densidade de UV local.
    func placeTattoo(at uv: SIMD2<Float>, uvUnitsPerMeter: Float) {
        placement = TattooPlacement(
            uv: uv,
            size: Self.defaultTattooWidth * uvUnitsPerMeter,
            rotation: placement?.rotation ?? 0,
            opacity: placement?.opacity ?? Self.defaultTattooOpacity
        )
    }

    func removeTattoo() {
        placement = nil
    }
}
