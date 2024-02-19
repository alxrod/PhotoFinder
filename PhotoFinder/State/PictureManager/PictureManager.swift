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
    var counter = 0
    
    
    func rotationToFaceDevice(newPos: SIMD3<Float>, curQuat: simd_quatf) -> simd_quatf {
        let devPos = deviceManager.getDeviceLocation()
            
        // Calculate direction vector from the entity to the device
        let direction = normalize(devPos - newPos)
        
        // Calculate horizontal component of the direction (for yaw)
        let horizontalDirection = normalize(SIMD3<Float>(direction.x, 0, direction.z))
        
        // Assuming the entity's forward vector is the negative Z-axis in its local space
        let globalForward = SIMD3<Float>(0, 0, 1)
        
        // Calculate yaw rotation (around Y-axis) to face the device horizontally
        let yawRotation = simd_quatf(from: globalForward, to: horizontalDirection)
        
        // Apply yaw rotation to the global up vector to get the entity's local up vector
        let localUp = yawRotation.act(SIMD3<Float>(0, 1, 0))
        
        // Calculate pitch rotation (around the entity's local X-axis) to tilt up or down towards the device's elevation
        // First, transform global forward vector by yaw rotation to align it with horizontal direction
        let alignedForward = yawRotation.act(globalForward)
        
        // Then, calculate quaternion that rotates alignedForward to the actual direction vector
        let pitchRotation = simd_quatf(from: alignedForward, to: direction)
        
        // Combine yaw and pitch rotations
        // Note: This assumes yawRotation already aligns the entity's forward direction with the horizontal projection
        // of the direction vector. The pitchRotation then adjusts the tilt up or down.
        let combinedRotation = pitchRotation * yawRotation
        
        return combinedRotation
    }
    
    
    // Function to update the location of a specific picture entity by index
    func updatePictureLoc(name: String, to newPos: SIMD3<Float>) {
        if !pictureEntityNameSet.contains(name) {
            return
        }
        for pictureEntity in pictureEntities {
            if pictureEntity.image.name == name {
                let rotationQuaternion = rotationToFaceDevice(newPos: newPos, curQuat: pictureEntity.orientation)

                pictureEntity.move(to: Transform(
                    scale: pictureEntity.scale,
                    rotation: rotationQuaternion,
                    translation: newPos), relativeTo: rootEntity)
                return
            }
        }
    }
    
    func updateSpecPictureLoc(pictureEntity: PictureEntity, newPos: SIMD3<Float>) {
        let rotationQuaternion = rotationToFaceDevice(newPos: newPos, curQuat: pictureEntity.orientation)

        pictureEntity.move(to: Transform(
            scale: pictureEntity.scale,
            rotation: rotationQuaternion,
            translation: newPos), relativeTo: rootEntity)
        return
    }
}


//let targetRotation = simd_quatf(from: forwardDirV, to: directionVector)
//
//// Detect if the current quaternion represents a rotation near 180 degrees
//if abs(curQuat.angle) > .pi - 0.01 { // Adjust the threshold as needed
//    print("TRIGGERING THRESHOOLD")
//    // Approach for handling near-180-degree rotations
//    // Here, we smoothly interpolate to the target rotation to avoid abrupt changes
//    
//    // Determine a safe interpolation factor; adjust this based on your application's needs
//    let t: Float = 0.1 // Example: small step towards target rotation
//    
//    // Slerp between the current quaternion and the target rotation
//    let newOrientation = simd_slerp(curQuat, targetRotation, t)
//    
//    return newOrientation.normalized
//} else {
//    // Handle the general case where the rotation is not near 180 degrees
//    // Your existing logic for calculating the new orientation
//    var newOrientation: simd_quatf
//    if abs(dot) > 0.985 {
//        // Handling for nearly parallel vectors as before
//        let isDirectionUpwards = dot > 0
//        let upVector = curQuat.act(SIMD3<Float>(0, 1, 0))
//        let rotationAxis = isDirectionUpwards ? upVector : -upVector
//        let angle = isDirectionUpwards ? 0.0 : .pi
//        newOrientation = simd_mul(curQuat, simd_quatf(angle: Float(angle), axis: rotationAxis))
//    } else {
//        // Calculate rotation as before
//        var cross = cross(currentForwardVector, directionVector)
//        if length(cross) < 0.001 {
//            cross = curQuat.act(SIMD3<Float>(0, 1, 0))
//        }
//        let rotationAxis = normalize(cross)
//        var angle = acos(min(max(dot, -1.0), 1.0))
//        let rotationDelta = simd_quatf(angle: angle, axis: rotationAxis)
//        newOrientation = simd_mul(curQuat, rotationDelta).normalized
//    }
//    
//    return newOrientation.normalized
//}
