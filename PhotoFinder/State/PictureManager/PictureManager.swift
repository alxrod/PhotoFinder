//
//  PictureManager.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/12/24.
//

import RealityKit
import UIKit
import SwiftUI

class PictureManager {
    let rootEntity = Entity()
    var pictureEntities: [PictureEntity] = []
    
    func addPicture(from image: UIImage, pos: SIMD3<Float>, rot: simd_quatf?, withSize size: SIMD2<Float> = [0.25, 0.25]) {
        let pictureEntity = PictureEntity(image: image, pos: pos, rot: rot, planeSize: size)
//        print("Created picture entity \(pictureEntity)")
        rootEntity.addChild(pictureEntity)
        pictureEntities.append(pictureEntity)
    }
}
