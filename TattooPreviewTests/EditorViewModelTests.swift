import Testing
@testable import TattooPreview

struct EditorViewModelTests {
    @Test func startsLoading() {
        let viewModel = EditorViewModel()

        #expect(viewModel.avatarState == .loading)
        #expect(viewModel.avatar == AvatarConfiguration())
        #expect(!viewModel.isAdjustingAvatar)
    }

    @Test func avatarDidLoadMarksLoaded() {
        let viewModel = EditorViewModel()

        viewModel.avatarDidLoad()

        #expect(viewModel.avatarState == .loaded)
    }

    @Test func avatarDidFailMarksFailed() {
        let viewModel = EditorViewModel()

        viewModel.avatarDidFail()

        #expect(viewModel.avatarState == .failed)
    }

    @Test func placeTattooUsesDefaultWidthInUVUnits() {
        let viewModel = EditorViewModel()

        viewModel.placeTattoo(at: [0.3, 0.6], uvUnitsPerMeter: 0.5)

        #expect(viewModel.placement == TattooPlacement(
            uv: [0.3, 0.6],
            size: EditorViewModel.defaultTattooWidth * 0.5,
            rotation: 0,
            opacity: EditorViewModel.defaultTattooOpacity
        ))
    }

    @Test func removeTattooClearsPlacement() {
        let viewModel = EditorViewModel()
        viewModel.placeTattoo(at: [0.3, 0.6], uvUnitsPerMeter: 0.5)

        viewModel.removeTattoo()

        #expect(viewModel.placement == nil)
    }
}
