//
//  EntityMovementViewModifier.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/15/24.
//

import Foundation
import RealityKit
import SwiftUI

struct EntityMovementViewModifier: ViewModifier {
    @EnvironmentObject private var model: ViewModel
    @State private var sourceTransform: Transform?
    @State private var sourceScale: SIMD3<Float> = SIMD3<Float>(-1,-1,-1)

    init() {
    }
    
    func extractPicEnt(starting: Entity) -> CustomEntity? {
        var traverser = starting
        var pictureEntity: PictureEntity?
        var pileEntity: PileEntity?
        var scale_factor = traverser.scale
        while let parent = traverser.parent {
            scale_factor *= parent.scale
            traverser = parent
            if let pEntity = traverser as? PictureEntity {
                pictureEntity = pEntity
            }
            if let pEntity = traverser as? PileEntity {
                pileEntity = pEntity
                return pileEntity
            }
        }
        if pictureEntity != nil {
            return pictureEntity
        }
        return nil
    }

    func body(content: Content) -> some View {
        
        let dragGesture = DragGesture(minimumDistance: 0.0)
            .targetedToAnyEntity()
            .onChanged { value in
                // Your existing drag gesture logic
                
                guard let entity = extractPicEnt(starting: value.entity) else { return }
                let convertedTranslation = value.convert(value.translation3D, from: .local, to: entity.parent!)
                if sourceTransform == nil {
                    sourceTransform = entity.transform
                }
                
                model.pictureManager.updateLoc(
                    entity: entity,
                    newPos: sourceTransform!.translation + SIMD3<Float>(convertedTranslation))
            }
            .onEnded { value in
                sourceTransform = nil
                guard let entity = extractPicEnt(starting: value.entity) else { return }
                
                if let picEntity = entity as? PictureEntity {
                    model.pictureManager.checkPictureCollisions(pictureEntity: picEntity)
                }
                
//                model.pictureManager
            }

        let magnifyGesture = MagnifyGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                // Your existing magnify gesture logic
                
                guard let pictureEntity = extractPicEnt(starting: value.entity) as? PictureEntity else { return }
                
                if sourceScale ==  SIMD3<Float>(-1,-1,-1) {
                    sourceScale = pictureEntity.scale
                }
                model.pictureManager.updateSpecPictureScale(
                    pictureEntity: pictureEntity,
                    newScale: 
                        max(
                            SIMD3<Float>(0.35, 0.35, 0.35),
                            sourceScale * Float(value.magnification)
                        )
                )
            }
            .onEnded { _ in
                sourceScale = SIMD3<Float>(-1,-1,-1)
            }
        
    
        let combinedGesture = SimultaneousGesture(dragGesture, magnifyGesture)
        
        content.gesture(combinedGesture)
        
    }
}

extension View {
    func enableMovingEntity() -> some View {
        modifier(EntityMovementViewModifier())
    }
}
