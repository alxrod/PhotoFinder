//
//  ContentView.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct StarterView: View {
    
    @EnvironmentObject private var model: ViewModel

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        GeometryReader3D { proxy3D in
            VStack {
                Text(model.titleText).font(.title)
                ImmersiveViewToggle()
                PreviewView().environmentObject(model)
            }
            .padding(70)
            .onAppear {
            }
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    StarterView()
}
