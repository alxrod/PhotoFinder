//
//  ImmersiveViewToggle.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import SwiftUI

struct ImmersiveViewToggle: View {
    @EnvironmentObject private var model: ViewModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {

        Toggle(model.isShowingImmersive ? Module.active.callToAction : Module.launch.callToAction, isOn: $model.isShowingImmersive)
            .onChange(of: model.isShowingImmersive) { _, isShowing in
                Task {
                    if isShowing {
                        await openImmersiveSpace(id: Module.active.name)
                    } else {
                        await dismissImmersiveSpace()
                    }
                }
            }
            .toggleStyle(.button)
    }
}

#Preview {
    ImmersiveViewToggle()
        .environmentObject(ViewModel())
}

