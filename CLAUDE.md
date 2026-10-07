# Tattoo Preview — contexto de arquitetura

App iOS nativo (Swift/SwiftUI) em que o usuário monta um avatar 3D estilo "criador de personagem de jogo", ajusta o corpo com sliders e posiciona uma tatuagem (PNG) sobre ele para ver como fica. Ferramenta pessoal de validação; decisões de produto, nome e monetização vêm depois.

"Tattoo Preview" é nome de trabalho e pode mudar. Módulos e classes usam nomes neutros (`Editor`, `Avatar`, `Tattoo`), sem derivar do nome do app.

## Escopo do MVP

- Avatar 3D com slider de peso/corpulência e presets de tom de pele
- Câmera orbital com zoom
- Importar PNG (Fotos e Arquivos)
- Posicionar a tatuagem tocando no corpo; arrastar, escala (pinça), rotação, opacidade e remover
- Persistir localmente o avatar e a tatuagem (restaurar ao reabrir o app)

Fora do MVP: nome final, monetização, conta de usuário, nuvem, múltiplas tatuagens simultâneas, identidade visual, altura do avatar (só faz sentido junto com tamanho da tatuagem em cm; quando vier, via blend shapes de altura do MPFB, não escala no eixo Y). Não implementar nem adicionar abstração especulativa para isso. Sem identidade visual ainda: só componentes/cores padrão do sistema.

## Arquitetura

- **MVVM**. ViewModel é `@Observable final class`, view segura via `@State private var viewModel = ...`.
- **Sem Coordinator**: o MVP é uma tela só (`Features/Editor`), com sheets para picker e ajustes. Introduzir `AppCoordinator` + `NavigationPath` só quando existir uma segunda tela de verdade.
- **Cena 3D fora do ViewModel**: o ViewModel guarda estado em value types (`AvatarConfiguration`, `TattooPlacement`). Um `AvatarSceneController` em `Core/Rendering/` é dono das entities do RealityKit e aplica esse estado na cena. ViewModel não importa RealityKit, para continuar testável.

## 3D

- RealityKit (`RealityView`), não SceneKit (soft-deprecated desde a WWDC25).
- Avatar em `.usdz` (`TattooPreview/Resources/Avatar/avatar.usdz`, gerado no Blender com MPFB/MakeHuman, CC0) com UV e blend shapes para peso/corpulência.
- Tom de pele por presets (escala Fitzpatrick I–VI), aplicados como `baseColor.tint` de um `PhysicallyBasedMaterial` sobre a textura de pele neutra/clara. Uma textura só, sem variação por tom.
- Câmera: `.realityViewCameraControls(.orbit)` (órbita + pinch-zoom nativos).
- Tatuagem pintada no espaço de textura: raycast contra os triângulos do mesh (cópia na CPU), cálculo do UV por coordenadas baricêntricas e composição do PNG na textura de pele em multiply (não alpha simples), com escala/rotação/opacidade; assim a mesma tinta perde contraste em pele escura, como na pele real. Assim a tatuagem acompanha o corpo quando os sliders mudam. Validada no spike (PR #3).

## Persistência

- Codable em JSON no Application Support + PNG da tatuagem como arquivo. Sem SwiftData/Core Data: é um registro só.

## Dependency Injection

- Manual: protocolo + injeção via `init`. Sem lib terceira.
- `@Environment(\.appDependencies)` é a única exceção, só para acesso cross-cutting a `AppDependencies` sem precisar de init-injection em toda view intermediária.
- Composition root é `AppDependencies` (`TattooPreview/Core/DI/AppDependencies.swift`). Novo serviço entra ali com um par protocolo+implementação em `TattooPreview/Core/Services/<Serviço>/`.

## Módulos

- Target único, pastas por feature (`TattooPreview/Features/<Feature>/`) e infraestrutura em `TattooPreview/Core/`. Não usar Swift Package local; não propor modularização por SPM sem pedido.

## Plataforma

- iPhone only, só retrato, iOS 27.0. Não reintroduzir iPad/macOS/visionOS nem paisagem sem decisão explícita.
- Bundle ID `com.rodrigogaleano.TattooPreview` fica fixo até o app ir para o App Store Connect.

## Teste

Swift Testing (`@Test`, `#expect`), não XCTest, para lógica nova. `TattooPreviewUITests` fica em XCTest (gerado pelo template, fora de escopo mudar).

## Lint

SwiftLint, config em `.swiftlint.yml`, gate obrigatório no CI (`.github/workflows/lint.yml`) antes de merge em `main`. Corrigir violação real no código, não silenciar ajustando a config, a menos que a regra não se aplique ao caso (ex: override de API do sistema).

## Git e PRs

- Commits e descrições de PR sem trailer `Co-Authored-By` e sem linha "Generated with Claude Code".
- PR no formato `## Summary` (1–2 linhas) + `## What's Included` (bullets curtos); título conventional commit; merge por squash.
