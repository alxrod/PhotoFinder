//
//  ImmersiveView.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    @EnvironmentObject private var model: ViewModel
    
    var body: some View {
        
        RealityView { content in
            // Add the initial RealityKit content
            
//            let cubeSize = SIMD3<Float>(0.2, 0.2, 0.2) // Smaller size for visibility
//            let material = SimpleMaterial(color: .red, isMetallic: false)
//            let cubeMesh = MeshResource.generateBox(size: cubeSize.x)
//            let cubeEntity = ModelEntity(mesh: cubeMesh, materials: [material])
//            cubeEntity.position = SIMD3<Float>(0, 0, -1) // Positioned 1 meter in front of the camera
            
            // Create an anchor and add the cube to it
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(model.pictureManager.rootEntity)
            content.add(model.pictureManager.rootEntity)
            
            Task {
//                 Run the ARKit session after the user opens the immersive space.
                await model.pictureManager.deviceManager.runARKitSession(arkitSession: model.arkitSession)
            }
            
        }
        .enableMovingEntity()
        .task {
            await model.pictureManager.deviceManager.processDeviceAnchorUpdates()
        }
        
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
