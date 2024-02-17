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

    init() {
    }

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0.0)
                    .targetedToAnyEntity()
                    .onChanged { value in
                        
                        //                       REPLACE THIS CODE WITH TRANSLATING THE DRAG GESTURE MOVEMENT TO MOVING THE ENTITY's location
//                        let entity = value.entity
//                        let convertedTranslation = value.convert(value.translation3D, from: .local, to: entity.parent!)
                        
                        
//                        if sourceTransform == nil {
//                            sourceTransform = entity.transform
//                        }
//                        entity.transform.translation = sourceTransform!.translation + SIMD3<Float>(convertedTranslation)
//                        
                        
                        var traverser = value.entity
                        var pictureEntity: PictureEntity?
                        var scale_factor = traverser.scale
                        while let parent = traverser.parent {
                            scale_factor *= parent.scale
                            traverser = parent
                            if let pEntity = traverser as? PictureEntity {
                                pictureEntity = pEntity
                                break
                            }
                        }
                        guard let pictureEntity = pictureEntity else { return }
                        
                        
                        let convertedTranslation = value.convert(value.translation3D, from: .local, to: pictureEntity.parent!)
                        if sourceTransform == nil {
                            sourceTransform = pictureEntity.transform
                        }
                            
//                        let trans = Transform(
//                            scale: pictureEntity.transform.scale,
//                            rotation: pictureEntity.transform.rotation,
//                            translation: sourceTransform!.translation + SIMD3<Float>(convertedTranslation))
                        
//
//                        let entToWorld = entity.convert(transform: trans, to: nil)
//                        let picTrans = pictureEntity.convert(transform: entToWorld, from: nil)
//                        pictureEntity.transform = trans
                        
//                      vs.
                        
//                        entity.transform = trans
                        
                        
                        
                        model.pictureManager.updateSpecPictureLoc(
                            pictureEntity: pictureEntity,
                            newPos: sourceTransform!.translation + SIMD3<Float>(convertedTranslation))
//
                        
//                        let newOrientation = model.pictureManager.rotationToFaceDevice(fromPosition: entity.transform.translation, curQuat: entity.transform.rotation)
//                        entity.transform
                    }
                    .onEnded { _ in
                        sourceTransform = nil
                    }
            )
    }
}

extension View {
    func enableMovingEntity() -> some View {
        modifier(EntityMovementViewModifier())
    }
}
