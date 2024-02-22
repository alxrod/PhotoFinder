//
//  ContentView.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct NavigationRoot: View {
    
    @EnvironmentObject private var model: ViewModel

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var navigateToNextView = false
    
    private let instructions = [
        "Drag images from the window anywhere in 3D space",
        "Place them ontop of eachother to form piles",
        "Tap on a pile to view it's content or remove any you don't want"
    ]

    var body: some View {
        VStack {
            NavigationStack(path: $model.navigationPath) {
                StarterView()
                .navigationDestination(for: Module.self) { module in
                    PileWindowView(module: module)
                        .navigationTitle(module.name)
                        .environmentObject(model)
                }.onAppear {
                    model.navigationPath = []
                    Task {
                        if model.isShowingImmersive {
                            await dismissImmersiveSpace()
                            model.isShowingImmersive = false
                        }
                    }
                }
            }
        }
        .onChange(of: model.navigationPath) { _, path in
            if !path.isEmpty && !model.isShowingImmersive {
                Task {
                    await openImmersiveSpace(id: ViewModel.pictureSpace)
                    model.isShowingImmersive = true
                }
            }
            if (path.isEmpty || !Module.isPile(path[path.count-1])) {
                if let selectedPile = model.pictureManager.selectedPile {
                    model.pictureManager.deSelectPile(selectedPile)
                }
            }
        }
    }
    
}

#Preview(windowStyle: .automatic) {
    StarterView()
}
