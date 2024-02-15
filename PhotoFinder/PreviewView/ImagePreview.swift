//
//  ImagePreview.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/14/24.
//

import SwiftUI
import RealityKit


struct ImagePreview: View {
    var image: UIImage
    var imageSize: CGFloat
    
    @State private var imageEntity: PictureEntity?
    @State private var cubeEntity: ModelEntity?
    
    
    var body: some View {
        RealityView { content in
//            let img = PictureEntity(image: image, planePosition: SIMD3<Float>(0.0, 0.0, 0.0), planeSize: SIMD2(0.1, 0.1))
//            content.add(img)
//            self.imageEntity = img
            let cubeMesh = MeshResource.generateBox(size: 0.05) // Adjust the size as needed
            let cubeMaterial = SimpleMaterial(color: .blue, isMetallic: false) // Adjust color and material properties as needed
            let cube = ModelEntity(mesh: cubeMesh, materials: [cubeMaterial])
            
            cube.components.set(InputTargetComponent())
            cube.generateCollisionShapes(recursive: true)
            
            cube.position = SIMD3<Float>(0.0, 0.0, 0.0) // Position the cube at the origin
            
            content.add(cube) // Add the cube to the content
            self.cubeEntity = cube
        }
//        .background(.red)
    }
}

