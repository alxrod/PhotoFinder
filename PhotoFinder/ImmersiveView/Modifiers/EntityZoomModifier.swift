//
//  EntityZoomModifier.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/20/24.
//

import Foundation
import RealityKit
import SwiftUI

struct EntityZoomViewModifier: ViewModifier {
    @EnvironmentObject private var model: ViewModel

    init() {
    }

    func body(content: Content) -> some View {
        content
            .gesture(MagnifyGesture()
                    .targetedToAnyEntity()
                    .onChanged { value in
                        print("MAGNIFYING \(value)")
                        
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
                        print("Zooming pictur \(pictureEntity) w value \(value)")
                        
//                        let convertedTranslation = value.convert(value.translation3D, from: .local, to: pictureEntity.parent!)
//                        if sourceTransform == nil {
//                            sourceTransform = pictureEntity.transform
//                        }
//                        
//                        model.pictureManager.updateSpecPictureLoc(
//                            pictureEntity: pictureEntity,
//                            newPos: sourceTransform!.translation + SIMD3<Float>(convertedTranslation))

                    }
//                    .onEnded { _ in
//                        sourceTransform = nil
//                    }
            )
    }
}

extension View {
    func enableZoomingEntity() -> some View {
        modifier(EntityZoomViewModifier())
    }
}

