import Foundation

nonisolated enum AvatarLoadState: Equatable {
    case loading
    case loaded
    case failed
}

@Observable
final class EditorViewModel {
    private(set) var avatarState: AvatarLoadState = .loading

    func avatarDidLoad() {
        avatarState = .loaded
    }

    func avatarDidFail() {
        avatarState = .failed
    }
}
