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
    var pileName: String = "Untitled"
    var pictureEntities: [PictureEntity] = []
    var textEntity: ModelEntity?
    var planeSize: SIMD2<Float>
    var pileId: String
    /// Initializes a new PileEntity.
    /// - Parameters:
    ///   - starterPosition: The starting position for the pile.
    ///   - pictureEntities: The list of PictureEntity instances to be stacked.
    init(pictureEntities: [PictureEntity]) {
        self.pileId = UUID().uuidString
        
        if pictureEntities.count > 0 {
            self.planeSize = pictureEntities[0].planeSize
            
            
            
            
            
        } else {
            self.planeSize = [0.25, 0.25]
        }
    
        super.init()
        
        if pictureEntities.count > 0 {
            let refPic = pictureEntities[pictureEntities.count / 2]
            self.position = refPic.position
            self.scale = refPic.scale
            self.orientation = refPic.orientation
        }
    
//        addOriginMarker()
        
        // Add and stack the picture entities
        addAndStackPictureEntities(pictureEntities)
        addTextLabel()
        
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
    
    func insertPic(_ entity: PictureEntity, offset: Float) {
        entity.image.space = .pile(pileId: self.pileId)
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
    
    
    func removeByName(_ name: String) -> PictureEntity? {
        // Remove the entity from the pictureEntities array
        let picEntity: PictureEntity
        if let index = pictureEntities.firstIndex(where: { $0.picName == name }) {
            picEntity = pictureEntities[index]
            pictureEntities.remove(at: index)
        } else {
            return nil
        }
        
        // Remove the entity from the PileEntity's children
        picEntity.removeFromParent()
        
        // Optionally, you might want to reset the entity's position, rotation, and other properties
        // if you plan to use it elsewhere in your scene or application
        picEntity.position = SIMD3<Float>(0, 0, 0)
        picEntity.orientation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 0, 1))
        picEntity.scale = SIMD3<Float>(1, 1, 1)
        
        return picEntity
        
        // If the entity's space property is set based on being in this pile, you may want to reset it as well
        // entity.image.space = .someOtherSpace // Adjust this based on your app's logic
    }
    
    func calculateBoundingBox() -> (min: SIMD3<Float>, max: SIMD3<Float>) {
        let reductionFactor = Float(0.5)
        let halfPlaneSize = (self.planeSize.x / 2)*reductionFactor //Come back to this later, fine cause assumed square currently
        
        var minCorner = SIMD3<Float>(self.position.x - halfPlaneSize, self.position.y - halfPlaneSize, self.position.z - halfPlaneSize)
        var maxCorner = SIMD3<Float>(self.position.x + halfPlaneSize, self.position.y + halfPlaneSize, self.position.z + halfPlaneSize)
        
        return (min: minCorner, max: maxCorner)
    }
    
    func isColliding(with entity: PictureEntity) -> Bool {
        let pileBoundingBox = calculateBoundingBox()
        let entityBoundingBox = entity.calculate3DBoundingBox()
        return doBoxesIntersect(pileBoundingBox, entityBoundingBox)
    }
 
}


extension PileEntity {
    func textGen(textString: String) -> ModelEntity {
        
        let materialVar = UnlitMaterial(color: .white)
        
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
        textEntity?.removeFromParent()
        
        let textEntity = textGen(textString: pileName)
        
        // Calculate the highest point and position the text entity
        let highestPoint = calculateHighestPoint()
        
        let xOffset = Float(-1*(0.05 * Double(pileName.count) / 2))
        let planeOffset = Float((planeSize.y*1.1)/2)
        let zOffset = Float(highestPoint + 0.05)
        
        textEntity.position = SIMD3<Float>(xOffset, planeOffset, zOffset) // Adjust the Z offset as necessary
        
        // Add the text entity as a child to the PileEntity
        self.addChild(textEntity)
        self.textEntity = textEntity
    }
    
    func rename(to newName: String) {
        // Update the pile name
        self.pileName = newName
        
        // Call addTextLabel to remove the old text entity and add a new one with the updated name
        addTextLabel()
    }

    func calculateHighestPoint() -> Float {
        // Assuming pictureEntities are stacked along the Z axis, find the highest Z value
        let highestEntity = pictureEntities.max(by: { $0.position.z < $1.position.z })
        return highestEntity?.position.z ?? 0
    }
}

extension PileEntity {
    func highlight() {
        for pic in pictureEntities {
            pic.highlight()
        }
    }
    
    func dehighlight() {
        for pic in pictureEntities {
            pic.dehighlight()
        }
    }
}
