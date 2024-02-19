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

    public var planeEntity: ModelEntity?

    public var cubeEntity: ModelEntity?
    public var image: NamedImage

    init(image: NamedImage, pos: SIMD3<Float>, rot: simd_quatf?, planeSize: SIMD2<Float> = [0.25, 0.25]) {
        self.image = image
        super.init()
        
        guard let cgImage = image.image.cgImage else { return }
        
        // Create texture from UIImage
//      May need to tweak semantic:
//      https://developer.apple.com/documentation/realitykit/textureresource/semantic-swift.enum
//      Semantic may need to be .color or .hdrColor
        
        let textureOptions = TextureResource.CreateOptions(semantic: .hdrColor)
        if let texture = try? TextureResource.generate(from: cgImage, options: textureOptions) {
////             Create material with the texture
            var material = UnlitMaterial()
            var baseColor = UnlitMaterial.BaseColor()
            baseColor.texture = PhysicallyBasedMaterial.Texture(texture)
            material.color = baseColor
//            let material = SimpleMaterial(color: .red, isMetallic: false)
//            
////             Create plane mesh with speGreat cified size
            let planeMesh = MeshResource.generatePlane(width: planeSize.x, height: planeSize.y)
            
//
//            // Create plane entity with the mesh and material
            planeEntity = ModelEntity(mesh: planeMesh, materials: [material])
            
//
//            // Add plane entity to the rotator
            if let planeEntity = planeEntity {
                planeEntity.generateCollisionShapes(recursive: true)
                planeEntity.components.set(InputTargetComponent())
                self.addChild(planeEntity)
            }

        }
        
        self.position = pos
        if let rot = rot {
            self.orientation = rot
        }
        
    }
    
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    static func == (lhs: PictureEntity, rhs: PictureEntity) -> Bool {
        // Compare UIImage instances by converting to PNG data for comparison
        // Note: This approach has limitations as mentioned above
        return lhs.image.name == rhs.image.name
    }
}
