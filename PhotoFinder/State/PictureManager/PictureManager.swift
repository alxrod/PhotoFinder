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
    
    var pileEntities: [PileEntity] = []
    let trashPileEntity = TrashPileEntity()
    
    var selectedPile: PileEntity?
    
    public var deviceManager: DeviceManager
    
    @MainActor
    init() {
        rootEntity.addChild(deviceLocation)
        rootEntity.addChild(trashPileEntity)
        pileEntities.append(trashPileEntity)
        trashPileEntity.position = SIMD3<Float>(-1.5,0.5,-2)
        deviceLocation.addChild(raycastOrigin)
        deviceManager = DeviceManager()
    }
    
    func addPicture(from image: NamedImage, pos: SIMD3<Float>, rot: simd_quatf?, withSize size: SIMD2<Float> = [0.25, 0.25]) {
        if pictureEntityNameSet.contains(image.name) {
            return
        }
        
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
    
    func rotationToFaceDeviceYAxisOnly(newPos: SIMD3<Float>, curQuat: simd_quatf) -> simd_quatf {
        let devPos = deviceManager.getDeviceLocation()
        
        // Calculate direction vector from the entity to the device
        let direction = normalize(devPos - newPos)
        
        // Calculate horizontal component of the direction (for yaw)
        let horizontalDirection = normalize(SIMD3<Float>(direction.x, 0, direction.z))
        
        // Assuming the entity's forward vector is the negative Z-axis in its local space
        let globalForward = SIMD3<Float>(0, 0, 1) // Ensure forward is correctly defined as negative Z-axis
        
        // Calculate yaw rotation (around Y-axis) to face the device horizontally
        let yawRotation = simd_quatf(from: globalForward, to: horizontalDirection)
        
        // Since we only want the yaw rotation, we return it directly without combining with a pitch rotation
        return yawRotation
    }

    
    func findPictureEntity(name: String) -> PictureEntity? {
        if !pictureEntityNameSet.contains(name) {
            return nil
        }
        for pictureEntity in pictureEntities {
            if pictureEntity.image.name == name {
                return pictureEntity
            }
        }
        return nil
    }
    
    func updateLoc(entity: CustomEntity, newPos: SIMD3<Float>) {
        let rotationQuaternion = !(entity is TrashPileEntity) ?
        rotationToFaceDevice(newPos: newPos, curQuat: entity.orientation) :
        rotationToFaceDeviceYAxisOnly(newPos: newPos, curQuat: entity.orientation)
        
        entity.move(to: Transform(
            scale: entity.scale,
            rotation: rotationQuaternion,
            translation: newPos), relativeTo: rootEntity)
        
        return
    }
    
    func updateSpecPictureScale(pictureEntity: PictureEntity, newScale: SIMD3<Float>) {
        pictureEntity.move(to: Transform(
            scale: newScale,
            rotation: pictureEntity.orientation,
            translation: pictureEntity.position), relativeTo: rootEntity)
    }
    
    func checkPictureCollisions(pictureEntity: PictureEntity) {
        
        for pile in pileEntities {
            print("CHECKING PILE ENTITY: \(pileEntities)")
            if pile.isColliding(with: pictureEntity) {
                addPictureToPile(pictureEntity: pictureEntity, pileEntity: pile)
                return
            }
        }
        
        var collidedWith: [PictureEntity] = []
        for picEnt in pictureEntities {
            if picEnt != pictureEntity && pictureEntity.isColliding(with: picEnt) {
                collidedWith.append(picEnt)
            }
        }
        if collidedWith.isEmpty {
            return
        }
        collidedWith.append(pictureEntity)
        self.createPileEntity(from: collidedWith, starterPosition: pictureEntity.position)
    }
}

