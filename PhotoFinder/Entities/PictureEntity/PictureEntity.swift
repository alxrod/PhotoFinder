//
//  PictureEntity.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/12/24.
//

import RealityKit
import UIKit
import SwiftUI

class PictureEntity: Entity, HasAnchoring {

    private let rotator: Entity = Entity()
    public var planeEntity: ModelEntity?

    public var cubeEntity: ModelEntity?

    init(image: UIImage, pos: SIMD3<Float>, rot: simd_quatf?, planeSize: SIMD2<Float> = [0.25, 0.25]) {
        super.init()
        
        guard let cgImage = image.cgImage else { return }
        
        // Create texture from UIImage
//      May need to tweak semantic:
//      https://developer.apple.com/documentation/realitykit/textureresource/semantic-swift.enum
//      Semantic may need to be .color or .hdrColor
        
        let textureOptions = TextureResource.CreateOptions(semantic: .hdrColor)
        if let texture = try? TextureResource.generate(from: cgImage, options: textureOptions) {
////             Create material with the texture
//            var material = UnlitMaterial()
//            var baseColor = UnlitMaterial.BaseColor()
//            baseColor.texture = PhysicallyBasedMaterial.Texture(texture)
//            material.color = baseColor
////            let material = SimpleMaterial(color: .red, isMetallic: false)
////            
//////             Create plane mesh with speGreat cified size
//            let planeMesh = MeshResource.generatePlane(width: planeSize.x, height: planeSize.y)
////            
////            // Create plane entity with the mesh and material
//            planeEntity = ModelEntity(mesh: planeMesh, materials: [material])
////            
////            // Add plane entity to the rotator
//            if let planeEntity = planeEntity {
//                rotator.addChild(planeEntity)
//            }
//            
            
//            Debugging Method:
            let cubeSize = SIMD3(planeSize.x, planeSize.x, planeSize.x)
            let material = SimpleMaterial(color: .gray, isMetallic: false)
            let cubeMesh = MeshResource.generateBox(size: cubeSize)
            planeEntity = ModelEntity(mesh: cubeMesh, materials: [material])
            rotator.addChild(planeEntity!)
            
        }
//        rotator.position = SIMD3<Float>(0, 1, -2)
        
        rotator.position = pos
        if let rot = rot {
            rotator.orientation = rot
        }
        
        
        // Add rotator to self
        self.addChild(rotator)
        
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
