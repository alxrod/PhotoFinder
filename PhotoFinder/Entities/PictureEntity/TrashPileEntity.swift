//
//  TrashPileEntity.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/22/24.
//

import Foundation
import RealityKit
import UIKit
import SwiftUI
import RealityKitContent
import ARKit
import ModelIO

class TrashPileEntity: PileEntity {
    
    var trashCanEntity: Entity?
    var height: Float = 0
    var width: Float = 0
    var depth: Float = 0
    
    required init() {
        super.init(pictureEntities: [])
        self.position = SIMD3<Float>(0,0,0)
        
        self.rename(to: "Trash")
        Task {
            await addTrashCanModel()
        }
    }
    
    override func insertPic(_ entity: PictureEntity, offset: Float) {
        entity.image.space = .pile(pileId: self.pileId)
        addRandomBall()
        pictureEntities.append(entity)
    }
    
    private func addTrashCanModel() async {
        guard let scene = await RealityKitContent.entity(named: "trashcan") else { return }
        trashCanEntity = scene
        trashCanEntity!.scale = SIMD3<Float>(1,1,1)
        self.addChild(trashCanEntity!)
        
        trashCanEntity!.generateCollisionShapes(recursive: true)

        if let trashCanEntity = trashCanEntity {
            var minHeight: Float = Float.greatestFiniteMagnitude
            var maxHeight: Float = -Float.greatestFiniteMagnitude
            var minWidth: Float = Float.greatestFiniteMagnitude
            var maxWidth: Float = -Float.greatestFiniteMagnitude
            var minDepth: Float = Float.greatestFiniteMagnitude
            var maxDepth: Float = -Float.greatestFiniteMagnitude
            
            // A recursive function to traverse the entity hierarchy
            func traverseEntityHierarchy(_ entity: Entity) {
                if let modelEntity = entity as? ModelEntity, let meshBounds = modelEntity.model?.mesh.bounds {
                    // Convert the modelEntity's local bounds to the coordinate space of the trashCanEntity
                    let modelEntityMinWorld = modelEntity.convert(position: meshBounds.min, to: trashCanEntity)
                    let modelEntityMaxWorld = modelEntity.convert(position: meshBounds.max, to: trashCanEntity)
                    
                    // Update the overall min and max heights
                    minHeight = min(minHeight, modelEntityMinWorld.y)
                    maxHeight = max(maxHeight, modelEntityMaxWorld.y)
                    minWidth = min(minWidth, modelEntityMinWorld.x)
                    maxWidth = max(maxHeight, modelEntityMaxWorld.x)
                    minDepth = min(minDepth, modelEntityMinWorld.z)
                    maxDepth = max(maxDepth, modelEntityMaxWorld.z)
                    
                }
                
                // Continue traversing for all children
                for child in entity.children {
                    traverseEntityHierarchy(child)
                }
            }
            
            // Start the traversal from the trashCanEntity
            traverseEntityHierarchy(trashCanEntity)
            
            // Calculate the total height
            trashCanEntity.generateCollisionShapes(recursive: true)
            trashCanEntity.components.set(InputTargetComponent())
            trashCanEntity.components.set(HoverEffectComponent())
            
            let totalHeight = maxHeight - minHeight
            let totalWidth = maxWidth - minWidth
            let totalDepth = maxDepth - minDepth
            
            height = totalHeight
            width = totalWidth
            depth = totalDepth
            
            textEntity!.position.y = height
        }
        
    }
    
    override func calculateBoundingBox() -> (min: SIMD3<Float>, max: SIMD3<Float>) {
        let reductionFactor = Float(0.5)
        let halfX = (width / 2) * reductionFactor //Come back to this later, fine cause assumed square currently
        let halfY = (height / 2) * reductionFactor
        let halfZ = (depth / 2) * reductionFactor
        
        var minCorner = SIMD3<Float>(self.position.x - halfX, self.position.y - halfY, self.position.z - halfZ)
        var maxCorner = SIMD3<Float>(self.position.x + halfX, self.position.y + halfY, self.position.z + halfZ)

        
        // Adjust the bounding box according to the PileEntity's position if necessary.
        // This step is needed if you're considering the pile's position as part of the bounding box.
        // minCorner += self.position
        // maxCorner +=  self.position
        
        print("Bounding box \(minCorner) \(maxCorner)")
        
        return (min: minCorner, max: maxCorner)
    }
    
    func addRandomBall() {
            // Assuming `width`, `height`, and `depth` are properties of TrashPileEntity
        let randomX = Float.random(in: -(width*0.3)/2...(width*0.3)/2)
            let randomY = Float.random(in: 0...height/2)
            let randomZ = Float.random(in: -(depth*0.3)/2...(depth*0.3)/2)
            
            // Generate a random color
            let randomColor = UIColor(
                red: CGFloat.random(in: 0...1),
                green: CGFloat.random(in: 0...1),
                blue: CGFloat.random(in: 0...1),
                alpha: 1.0
            )
            
            // Create the icosahedron
            let icosahedron = createGeodesicIcosahedron(color: randomColor) // Adjust radius as needed
            
            // Set the position of the icosahedron
            icosahedron.position = SIMD3<Float>(randomX, randomY, randomZ)
            
            // Add the icosahedron to the TrashPileEntity
            self.addChild(icosahedron)
        }
    
    func createGeodesicIcosahedron(color: UIColor) -> Entity {
        // Create a sphere with the given radius
        let sphereMesh = MeshResource.generateSphere(radius: width/20)
        let sphere = ModelEntity(mesh: sphereMesh, materials: [UnlitMaterial(color: color)])
        return sphere
    }

}


