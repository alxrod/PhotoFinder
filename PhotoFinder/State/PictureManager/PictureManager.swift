//
//  DeviceManager.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/16/24.
//

import Foundation
import RealityKit
import UIKit
import SwiftUI
import simd

class PictureManager {
    let rootEntity = Entity()
    
    var deviceLocation = Entity()
    var raycastOrigin = Entity()

    var pictureEntities: [PictureEntity] = []
    var pictureEntityNameSet: Set<String> = []
    
    public var deviceManager: DeviceManager
    
    @MainActor
    init() {
        rootEntity.addChild(deviceLocation)
        deviceLocation.addChild(raycastOrigin)
        deviceManager = DeviceManager()
    }
    
    func addPicture(from image: NamedImage, pos: SIMD3<Float>, rot: simd_quatf?, withSize size: SIMD2<Float> = [0.25, 0.25]) {
        if pictureEntityNameSet.contains(image.name) {
            return
        }
        
        print("Adding picture \(image)")
        let pictureEntity = PictureEntity(image: image, pos: pos, rot: rot, planeSize: size)
        pictureEntityNameSet.insert(image.name)
//        print("Created picture entity \(pictureEntity)")
        rootEntity.addChild(pictureEntity)
        pictureEntities.append(pictureEntity)
    }
    
    
//    Calculate from starter lcoation
    func rotationToFaceDevice(fromPosition: SIMD3<Float>, curQuat: simd_quatf) -> simd_quatf {
        let toPosition = deviceManager.getDeviceLocation()
        
        let directionVector = normalize(toPosition - fromPosition)
        
        // Transform the forward vector by the current quaternion to get the object's current forward direction
        let forwardDirV = SIMD3<Float>(0,0,1)
        let currentForwardVector = curQuat.act(forwardDirV)
        
        // Calculate the rotation angle using dot product between the current forward vector and the direction vector
        let dot = dot(currentForwardVector, directionVector)
        let clampedDot = max(-1.0, min(1.0, dot)) // Clamp to ensure the value is within the valid range for acos
        let angle = acos(clampedDot)
        
        // Calculate cross product to determine the rotation axis
        let cross = cross(currentForwardVector, directionVector)
        
        // Normalize the rotation axis to ensure it is a unit vector
        let rotationAxis = normalize(cross)
        
        // Create quaternion for the rotation from the current orientation to the target orientation
        // This quaternion represents the rotation needed to align the current forward direction with the target direction
        let rotationDelta = simd_quatf(angle: angle, axis: rotationAxis)
        
        // Combine the current orientation with the rotation delta to get the new orientation
        // This ensures the rotation is relative to the current orientation of the object
        var newOrientation = simd_mul(curQuat, rotationDelta)
        
//      Apply roizon leveling
        let upVector = newOrientation.act(SIMD3<Float>(0, 1, 0))
        // Project the 'up' vector onto the global Y-axis to find the correction rotation
        let correctionAxis = simd_cross(upVector, SIMD3<Float>(0, 1, 0))
        let correctionAngle = asin(length(correctionAxis) / length(upVector))
        // Create a quaternion for the correction rotation if necessary
        if correctionAngle > 0.001 { // Apply correction only if there's a significant deviation
            let correctionRotation = simd_quatf(angle: correctionAngle, axis: normalize(correctionAxis))
            // Apply the correction rotation to align the 'up' vector with the global Y-axis
            newOrientation = simd_mul(newOrientation, correctionRotation)
        }
    
        return newOrientation
    }

    //
    
    // Function to update the location of a specific picture entity by index
    func updatePictureLoc(name: String, to newPos: SIMD3<Float>) {
        if !pictureEntityNameSet.contains(name) {
            return
        }
        for pictureEntity in pictureEntities {
            if pictureEntity.image.name == name {
                let rotationQuaternion = rotationToFaceDevice(fromPosition: newPos, curQuat: pictureEntity.orientation)
                print(rotationQuaternion)
                            
                pictureEntity.move(to: Transform(
                    scale: pictureEntity.scale,
                    rotation: rotationQuaternion,
                    translation: newPos), relativeTo: rootEntity)
                return
            }
        }
    }
    
    func updateSpecPictureLoc(pictureEntity: PictureEntity, newPos: SIMD3<Float>) {
        let rotationQuaternion = rotationToFaceDevice(fromPosition: newPos, curQuat: pictureEntity.orientation)
        print(rotationQuaternion)

        pictureEntity.transform.translation = newPos
        pictureEntity.transform.rotation = rotationQuaternion
        return
    }
}
