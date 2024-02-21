//
//  CustomEntity.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/20/24.
//

import Foundation
import RealityKit

class CustomEntity: Entity {
    // Custom functionality common to all entities can be added here
    // For now, it's just a basic subclass of Entity
    
    /// Helper function to determine if two bounding boxes intersect.
    func doBoxesIntersect(_ box1: (min: SIMD3<Float>, max: SIMD3<Float>), _ box2: (min: SIMD3<Float>, max: SIMD3<Float>)) -> Bool {
        let intersectX = box1.max.x >= box2.min.x && box1.min.x <= box2.max.x
        let intersectY = box1.max.y >= box2.min.y && box1.min.y <= box2.max.y
        let intersectZ = box1.max.z >= box2.min.z && box1.min.z <= box2.max.z
        return intersectX && intersectY && intersectZ
    }
    
}
