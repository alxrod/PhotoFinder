//
//  PictureManagerPile.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/20/24.
//

import Foundation
import RealityKit

extension PictureManager {
    func createPileEntity(from inputPictures: [PictureEntity], starterPosition: SIMD3<Float>) -> PileEntity {
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
        return pileEntity
    }
    
    func addPictureToPile(pictureEntity: PictureEntity, pileEntity: PileEntity) {
        pictureEntity.removeFromParent()
        
        // 2) Remove all of the inputPictures from the pictureEntities array and pictureEntityNameSet
        if let index = self.pictureEntities.firstIndex(of: pictureEntity) {
            self.pictureEntities.remove(at: index)
            pictureEntityNameSet.remove(pictureEntity.image.name)
            pictureEntity.image.space = ImageSpace.pile(pileId: pileEntity.pileId)
        }

        pileEntity.append(pictureEntity)
    }
    
    func removeFromPileByName(_ picEntityName: String, pileEntityId: String) {
        let pileEntityIdx = pileEntities.firstIndex { $0.pileId == pileEntityId }
        
        guard let idx = pileEntityIdx else {return}
        let pileEntity = pileEntities[idx]
        
        let picEntity = pileEntity.removeByName(picEntityName)
        
        if pileEntity.pictureEntities.isEmpty && !(pileEntity is TrashPileEntity) {
            pileEntity.removeFromParent()
            self.pileEntities.remove(at: idx)
        }
    }
    
    func selectPile(_ pileEntity: PileEntity) {
        if let oldPile = self.selectedPile {
            oldPile.dehighlight()
        }
        self.selectedPile = pileEntity
        self.selectedPile?.highlight()
    }
    
    func deSelectPile(_ pileEntity: PileEntity) {
        if let oldPile = self.selectedPile {
            oldPile.dehighlight()
        }
        self.selectedPile = nil
    }
    
    func getPileIdPics(_ pileId: String) -> [NamedImage] {
        let pileEntity = pileEntities.first { $0.pileId == pileId }
        guard let pileEntity = pileEntity else {return []}
        var images: [NamedImage] = []
        for picEnt in pileEntity.pictureEntities {
            images.append(picEnt.image)
        }
        return images
    }
}


