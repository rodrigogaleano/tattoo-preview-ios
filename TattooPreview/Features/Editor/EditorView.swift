import RealityKit
import SwiftUI

struct EditorView: View {
    @State private var viewModel: EditorViewModel
    @State private var sceneController = AvatarSceneController()

    init(viewModel: EditorViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        RealityView { content in
            content.camera = .virtual
            content.add(sceneController.root)
        }
        .realityViewCameraControls(.orbit)
        .background(Color(.systemBackground))
        .overlay {
            switch viewModel.avatarState {
            case .loading:
                ProgressView()
            case .failed:
                ContentUnavailableView("Avatar indisponível", systemImage: "figure.stand")
            case .loaded:
                EmptyView()
            }
        }
        .task {
            do {
                try await sceneController.loadAvatar()
                viewModel.avatarDidLoad()
            } catch {
                viewModel.avatarDidFail()
            }
        }
    }
}

#Preview {
    EditorView(viewModel: EditorViewModel())
}
