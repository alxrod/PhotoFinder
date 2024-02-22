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
            NavigationRoot()
                .environmentObject(model)
        }

        ImmersiveSpace(id: ViewModel.pictureSpace) {
            ImmersiveView()
                .environmentObject(model)
        }.immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
