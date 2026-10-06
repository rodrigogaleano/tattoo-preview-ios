import SwiftUI

struct EditorView: View {
    @State private var viewModel: EditorViewModel

    init(viewModel: EditorViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Text(viewModel.title)
            .font(.title)
            .padding()
    }
}

#Preview {
    EditorView(viewModel: EditorViewModel())
}
