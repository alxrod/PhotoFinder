//
//  File.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/20/24.
//

import Foundation
import RealityKit
import UIKit
import SwiftUI

class PileEntity: CustomEntity {
    var pileName: String = "Trapp Family Lodge Trip"
    var pictureEntities: [PictureEntity] = []
    var planeSize: SIMD2<Float>

    /// Initializes a new PileEntity.
    /// - Parameters:
    ///   - starterPosition: The starting position for the pile.
    ///   - pictureEntities: The list of PictureEntity instances to be stacked.
    init(pictureEntities: [PictureEntity]) {
        self.planeSize = pictureEntities[0].planeSize
        super.init()
        let refPic = pictureEntities[pictureEntities.count / 2]
        self.position = refPic.position
        self.scale = refPic.scale
        self.orientation = refPic.orientation
        

//        addOriginMarker()
        
        // Add and stack the picture entities
        addAndStackPictureEntities(pictureEntities)
        addTextLabel()
        print("MAKING PILE at pos \(self.position)")
        
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func addOriginMarker() {
        let sphereMesh = MeshResource.generateSphere(radius: 0.02) // Adjust the radius as needed
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [material])
        
        // Since this sphere is a direct child of the PileEntity and we're adding it at the origin,
        // its position is (0, 0, 0) by default, which is exactly where we want it relative to the PileEntity.
        self.addChild(sphereEntity)
    }
    
    func append(_ entity: PictureEntity) {
        // Calculate the new Z offset based on the number of entities and the spacing
        let spacing: Float = 0.01 // Assuming this is the same spacing used in addAndStackPictureEntities
        let currentZOffset = Float(pictureEntities.count) * spacing
        
        insertPic(entity, offset: currentZOffset)
    }
    
    private func addAndStackPictureEntities(_ entities: [PictureEntity]) {
        var currentZOffset: Float = 0.0
        let spacing: Float = 0.01 // Spacing between entities in the stack, adjust as needed

        for entity in entities {
            // Set the newPosition relative to the PileEntity's origin
            insertPic(entity, offset: currentZOffset)
            currentZOffset += spacing
        }
    }
    
    private func insertPic(_ entity: PictureEntity, offset: Float) {
        
        entity.position = SIMD3<Float>(0,0,offset)
        // Generate a random rotation around the Z-axis
        let minAngleDegrees: Float = -35
        let maxAngleDegrees: Float = 35
        let minAngleRadians = minAngleDegrees * (Float.pi / 180)
        let maxAngleRadians = maxAngleDegrees * (Float.pi / 180)
        
        // Generate a random rotation around the Z-axis within the specified limits
        let randomAngle = Float.random(in: minAngleRadians...maxAngleRadians) // Random angle in radians
        let rotation = simd_quatf(angle: randomAngle, axis: SIMD3<Float>(0, 0, 1))
        
        // Apply the random rotation to the entity
        entity.scale = SIMD3<Float>(1,1,1)
        entity.orientation = rotation
        
        // Add the entity as a child to the PileEntity
        self.addChild(entity)
        pictureEntities.append(entity)
    }
 
}


extension PileEntity {
    
    /// Checks for a collision between the pile's bounding box and a given PictureEntity.
    func isColliding(with entity: PictureEntity) -> Bool {
        let pileBoundingBox = calculateBoundingBox()
        let entityBoundingBox = entity.calculate3DBoundingBox()
        print("Testing collision between pile: \(pileBoundingBox) and pic \(entity)")
        return doBoxesIntersect(pileBoundingBox, entityBoundingBox)
    }
    
    /// Calculates the bounding box that encompasses all picture entities within the pile.
    func calculateBoundingBox() -> (min: SIMD3<Float>, max: SIMD3<Float>) {
        let halfPlaneSize = self.pictureEntities[0].planeSize.x / 2 //Come back to this later, fine cause assumed square currently
        
        var minCorner = SIMD3<Float>(self.position.x - halfPlaneSize, self.position.y - halfPlaneSize, self.position.z - halfPlaneSize)
        var maxCorner = SIMD3<Float>(self.position.x + halfPlaneSize, self.position.y + halfPlaneSize, self.position.z + halfPlaneSize)

        
        // Adjust the bounding box according to the PileEntity's position if necessary.
        // This step is needed if you're considering the pile's position as part of the bounding box.
        // minCorner += self.position
        // maxCorner +=  self.position
        
        return (min: minCorner, max: maxCorner)
    }
    
}


extension PileEntity {
    func textGen(textString: String) -> ModelEntity {
        
        let materialVar = SimpleMaterial(color: .white, roughness: 0, isMetallic: false)
        
        let depthVar: Float = 0.001
        let fontVar = UIFont.systemFont(ofSize: 0.05)
        let desiredWidth = 0.05 * Double(pileName.count)
        let containerFrameVar = CGRect(x: 0, y: 0, width: desiredWidth, height: 0.1)
        let alignmentVar: CTTextAlignment = .center
        let lineBreakModeVar : CTLineBreakMode = .byWordWrapping
        
        let textMeshResource : MeshResource = .generateText(textString,
                                           extrusionDepth: depthVar,
                                           font: fontVar,
                                           containerFrame: containerFrameVar,
                                           alignment: alignmentVar,
                                           lineBreakMode: lineBreakModeVar)
        
        let textEntity = ModelEntity(mesh: textMeshResource, materials: [materialVar])
        
        return textEntity
    }
    
    func addTextLabel() {
        let textEntity = textGen(textString: pileName)
        
        // Calculate the highest point and position the text entity
        let highestPoint = calculateHighestPoint()
        
        let xOffset = Float(-1*(0.05 * Double(pileName.count) / 2))
        let planeOffset = Float((planeSize.y*1.1)/2)
        let zOffset = Float(highestPoint + 0.05)
        textEntity.position = SIMD3<Float>(xOffset, planeOffset, zOffset) // Adjust the Z offset as necessary
        
        // Add the text entity as a child to the PileEntity
        self.addChild(textEntity)
    }

    func calculateHighestPoint() -> Float {
        // Assuming pictureEntities are stacked along the Z axis, find the highest Z value
        let highestEntity = pictureEntities.max(by: { $0.position.z < $1.position.z })
        return highestEntity?.position.z ?? 0
    }
}
