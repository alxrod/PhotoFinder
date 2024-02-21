//
//  PictureManagerPile.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/20/24.
//

import Foundation
import RealityKit

extension PictureManager {
    func createPileEntity(from inputPictures: [PictureEntity], starterPosition: SIMD3<Float>) {
        // 1) Remove all of the inputPictures from the root entity
        inputPictures.forEach { $0.removeFromParent() }
        
        // 2) Remove all of the inputPictures from the pictureEntities array and pictureEntityNameSet
        self.pictureEntities.removeAll { pictureEntity in
            if let index = inputPictures.firstIndex(where: { $0 == pictureEntity }) {
                pictureEntityNameSet.remove(inputPictures[index].image.name)
                return true
            }
            return false
        }
        
        // 3) Creates a PileEntity with all of the inputPictures
        let pileEntity = PileEntity(pictureEntities: inputPictures)
        
        // 4) Adds the pileEntity to the rootEntity
        rootEntity.addChild(pileEntity)
        print("Pile entity created as: \(rootEntity)")
        
        // 5) Adds the PileEntity to a classwide array of all pileEntities
        pileEntities.append(pileEntity)
    }
    
    func addPictureToPile(pictureEntity: PictureEntity, pileEntity: PileEntity) {
        pictureEntity.removeFromParent()
        
        // 2) Remove all of the inputPictures from the pictureEntities array and pictureEntityNameSet
        if let index = self.pictureEntities.firstIndex(of: pictureEntity) {
            self.pictureEntities.remove(at: index)
            pictureEntityNameSet.remove(pictureEntity.image.name)
        }

        pileEntity.append(pictureEntity)
    }
}
