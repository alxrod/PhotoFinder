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
                        
                        model.pictureManager.updateSpecPictureLoc(
                            pictureEntity: pictureEntity,
                            newPos: sourceTransform!.translation + SIMD3<Float>(convertedTranslation))

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
