//
//  PhotoFinderApp.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import SwiftUI
import RealityKitContent

@main
@MainActor
struct PhotoFinderApp: App {
    
    @State private var model = ViewModel()
    
    var body: some Scene {
        WindowGroup(id: "launcher") {
            StarterView()
                .environmentObject(model)
        }

        ImmersiveSpace(id: Module.active.name) {
            ImmersiveView()
                .environmentObject(model)
        }.immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
