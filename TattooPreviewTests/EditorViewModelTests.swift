import Testing
@testable import TattooPreview

struct EditorViewModelTests {
    @Test func titleIsEditor() {
        let viewModel = EditorViewModel()

        #expect(viewModel.title == "Editor")
    }
}
