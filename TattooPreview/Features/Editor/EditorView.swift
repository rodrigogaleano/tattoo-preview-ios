import RealityKit
import SwiftUI

struct EditorView: View {
    @State private var viewModel: EditorViewModel
    @State private var sceneController = AvatarSceneController()
    @State private var pendingTap: CGPoint?

    init(viewModel: EditorViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        RealityView { content in
            content.camera = .virtual
            content.add(sceneController.root)
        } update: { content in
            guard let point = pendingTap else { return }
            let ray = content.ray(through: point, in: .local, to: .scene)
            Task { @MainActor in
                pendingTap = nil
                if let ray {
                    handleTap(origin: ray.origin, direction: ray.direction)
                }
            }
        }
        .realityViewCameraControls(.orbit)
        #if DEBUG
        .gesture(SpatialTapGesture(coordinateSpace: .local).onEnded { pendingTap = $0.location })
        .safeAreaInset(edge: .bottom) { DebugTattooPanel(viewModel: viewModel) }
        #endif
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
        .onChange(of: viewModel.skinTone) { _, tone in
            sceneController.applySkinTone(tone)
        }
        .onChange(of: viewModel.bodyWeight) { _, weight in
            sceneController.setBodyWeight(weight)
        }
        .onChange(of: viewModel.placement) { _, placement in
            applyTattoo(placement)
        }
    }

    private func handleTap(origin: SIMD3<Float>, direction: SIMD3<Float>) {
        guard let hit = sceneController.hitTest(origin: origin, direction: direction) else { return }
        viewModel.placeTattoo(at: hit.uv, uvUnitsPerMeter: hit.uvUnitsPerMeter)
    }

    private func applyTattoo(_ placement: TattooPlacement?) {
        #if DEBUG
        guard let image = DebugTattoo.image else { return }
        try? sceneController.applyTattoo(image, placement: placement)
        #endif
    }
}

#if DEBUG
/// Tatuagem e controles provisórios do spike; importação e ajustes de verdade chegam nos PRs 3, 5 e 7.
private enum DebugTattoo {
    static let image: CGImage? = {
        let size = CGSize(width: 512, height: 512)
        let configuration = UIImage.SymbolConfiguration(pointSize: 400, weight: .regular)
        guard let symbol = UIImage(systemName: "sun.max", withConfiguration: configuration)?
            .withTintColor(.black, renderingMode: .alwaysOriginal) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: size, format: .init(for: .init(displayScale: 1)))
        return renderer.image { _ in
            let scale = min(size.width / symbol.size.width, size.height / symbol.size.height)
            let fitted = CGSize(width: symbol.size.width * scale, height: symbol.size.height * scale)
            symbol.draw(in: CGRect(
                x: (size.width - fitted.width) / 2, y: (size.height - fitted.height) / 2,
                width: fitted.width, height: fitted.height
            ))
        }.cgImage
    }()
}

private struct DebugTattooPanel: View {
    @Bindable var viewModel: EditorViewModel

    var body: some View {
        VStack(spacing: 8) {
            Picker("Tom", selection: $viewModel.skinTone) {
                Text("I").tag(SkinTone.typeI)
                Text("III").tag(SkinTone.typeIII)
                Text("VI").tag(SkinTone.typeVI)
            }
            .pickerStyle(.segmented)
            HStack {
                Text("Peso")
                Slider(value: $viewModel.bodyWeight, in: -1...1)
                Button("Remover", systemImage: "trash", action: viewModel.removeTattoo)
                    .labelStyle(.iconOnly)
                    .disabled(viewModel.placement == nil)
            }
        }
        .padding()
        .background(.regularMaterial)
    }
}
#endif

#Preview {
    EditorView(viewModel: EditorViewModel())
}
