//
//  PictureManager.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/12/24.
//

import Foundation
import ARKit
import RealityKit
import QuartzCore
import SwiftUI


class DeviceManager {
    
    private let deviceLocation: Entity
    private let raycastOrigin: Entity
    
    private let worldTracking = WorldTrackingProvider()
    private var deviceAnchorPresent = false
    
    @MainActor
    init() {
        deviceLocation = Entity()
        raycastOrigin = Entity()

        
        deviceLocation.addChild(raycastOrigin)
        
        // Angle raycasts 15 degrees down.
        let raycastAngle = 0 * (Float.pi / 180)
        raycastOrigin.orientation = simd_quatf(angle: -raycastAngle, axis: [1.0, 0.0, 0.0])
    }
    
    func processDeviceAnchorUpdates() async {
        await run(function: self.queryAndProcessLatestDeviceAnchor, withFrequency: 90)
    }
    
    @MainActor
    func runARKitSession(arkitSession: ARKitSession) async {
        do {
            // Run a new set of providers every time when entering the immersive space.
            try await arkitSession.run([worldTracking])
        } catch {
            // No need to handle the error here; the app is already monitoring the
            // session for error.
            return
        }
    }
    
    @MainActor
    private func queryAndProcessLatestDeviceAnchor() async {
        // Device anchors are only available when the provider is running.
        guard worldTracking.state == .running else { return }
        
        let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())

        deviceAnchorPresent = deviceAnchor != nil
        
        guard let deviceAnchor, deviceAnchor.isTracked else { return }
        await updatePlacementLocation(deviceAnchor)
    }
    
    @MainActor
    private func updatePlacementLocation(_ deviceAnchor: DeviceAnchor) async {
        deviceLocation.transform = Transform(matrix: deviceAnchor.originFromAnchorTransform)
//      Do work to calculate looking direction in future
    }
    
    public func getDeviceLocation() -> SIMD3<Float> {
        return SIMD3<Float>(self.deviceLocation.position)
    }
    
}

extension DeviceManager {
    /// Run a given function at an approximate frequency.
    ///
    /// > Note: This method doesn’t take into account the time it takes to run the given function itself.
    @MainActor
    func run(function: () async -> Void, withFrequency hz: UInt64) async {
        while true {
            if Task.isCancelled {
                return
            }
            
            // Sleep for 1 s / hz before calling the function.
            let nanoSecondsToSleep: UInt64 = NSEC_PER_SEC / hz
            do {
                try await Task.sleep(nanoseconds: nanoSecondsToSleep)
            } catch {
                // Sleep fails when the Task is cancelled. Exit the loop.
                return
            }
            
            await function()
        }
    }
    
}

