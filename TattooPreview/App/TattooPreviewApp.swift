//
//  TattooPreviewApp.swift
//  TattooPreview
//
//  Created by Rodrigo Galeano on 06/10/26.
//

import SwiftUI

@main
struct TattooPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            EditorView(viewModel: EditorViewModel())
                .environment(\.appDependencies, .live)
        }
    }
}
