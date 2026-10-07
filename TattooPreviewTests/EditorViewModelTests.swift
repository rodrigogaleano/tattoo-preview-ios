import Testing
@testable import TattooPreview

struct EditorViewModelTests {
    @Test func startsLoading() {
        let viewModel = EditorViewModel()

        #expect(viewModel.avatarState == .loading)
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
}
