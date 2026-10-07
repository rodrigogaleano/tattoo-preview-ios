# Tattoo Preview

App iOS nativo (SwiftUI) para testar tatuagens virtualmente. Você monta um avatar 3D, ajusta o corpo com sliders e posiciona uma tatuagem (PNG) sobre ele para ver como fica.

"Tattoo Preview" é nome de trabalho e pode mudar.

## Requisitos

- Xcode 26.6+
- iOS 27.0+ (deployment target do projeto)
- iPhone apenas, só retrato (iPad/macOS/visionOS fora de escopo)

## Rodando

```bash
open TattooPreview.xcodeproj
```

Ou via linha de comando:

```bash
xcodebuild build -project TattooPreview.xcodeproj -scheme TattooPreview \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' -configuration Debug

xcodebuild test -project TattooPreview.xcodeproj -scheme TattooPreview \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' -only-testing:TattooPreviewTests
```

## Arquitetura

- **MVVM**: um ViewModel `@Observable` por tela. Sem Coordinator enquanto o app tiver uma tela só.
- **3D**: RealityKit. A cena é gerenciada por um controller em `Core/Rendering`, fora do ViewModel.
- **DI manual**: protocolo + injeção via `init`, sem lib terceira. `@Environment` só para `AppDependencies` (caso cross-cutting).
- **Módulos**: target único, pastas por feature (`TattooPreview/Features/*`) e infraestrutura em `TattooPreview/Core/*`.
- **Teste**: Swift Testing (`@Test`), não XCTest.

Detalhes e decisões registradas em [CLAUDE.md](CLAUDE.md).

## Avatar

- Modelo base em `TattooPreview/Resources/Avatar/avatar.usdz`, gerado com [MPFB](https://static.makehumancommunity.org/mpfb.html) (MakeHuman para Blender, assets CC0).
- Corpo neutro, sem roupa/cabelo, pele clara pouco saturada (o tom vem de presets no app).
- Shape keys de peso/corpulência mantidas; export USD (.usdz) com UV, Shape Keys, Armature e Materials.
- `AvatarAssetTests` valida mesh, UV e blend shapes do arquivo.

## Lint

SwiftLint roda no CI (`.github/workflows/lint.yml`) em todo PR para `main`. Rodar localmente:

```bash
brew install swiftlint
swiftlint lint --strict
```
