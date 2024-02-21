//
//  PictureEntity.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/12/24.
//

import RealityKit
import UIKit
import SwiftUI

class PictureEntity: CustomEntity {

    public var planeEntity: ModelEntity?

    public var cubeEntity: ModelEntity?
    public var planeSize: SIMD2<Float>
    public var image: NamedImage

    init(image: NamedImage, pos: SIMD3<Float>, rot: simd_quatf?, planeSize: SIMD2<Float> = [0.25, 0.25]) {
        self.planeSize = planeSize
        self.image = image
        super.init()
        
        guard let cgImage = image.image.cgImage else { return }
        
        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)
        let cropSize = min(originalWidth, originalHeight)
        let cropRect = CGRect(x: (originalWidth - cropSize) / 2, y: (originalHeight - cropSize) / 2, width: cropSize, height: cropSize)
        
        // Crop the image to a square at its center
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return }
    
        let textureOptions = TextureResource.CreateOptions(semantic: .hdrColor)
        if let texture = try? TextureResource.generate(from: croppedCGImage, options: textureOptions) {
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


extension PictureEntity {
    
    func isColliding(with entity: PictureEntity) -> Bool {
        // Assume depth is a property of PictureEntity, or specify a fixed value if it's constant

        // Calculate the 3D bounding boxes for both entities
        let box1 = self.calculate3DBoundingBox()
        let box2 = entity.calculate3DBoundingBox()

        // Check if the 3D bounding boxes intersect
        return doBoxesIntersect(box1, box2)
    }
    

    func calculate3DBoundingBox() -> (min: SIMD3<Float>, max: SIMD3<Float>) {
        // Assume the entity's position is the center of the bounding box.
        let center = self.position
        
        // Calculate half extents based on the entity's plane size and the specified depth.
        let halfWidth = self.planeEntity?.model?.mesh.bounds.extents.x ?? 0 / 2
        let halfHeight = self.planeEntity?.model?.mesh.bounds.extents.y ?? 0 / 2
        let halfDepth = halfWidth / 2
        
        // Calculate the min and max corners of the bounding box.
        let minCorner = SIMD3<Float>(center.x - halfWidth, center.y - halfHeight, center.z - halfDepth)
        let maxCorner = SIMD3<Float>(center.x + halfWidth, center.y + halfHeight, center.z + halfDepth)
        
        return (min: minCorner, max: maxCorner)
    }
}
