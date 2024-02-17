//
//  ViewModel.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import SwiftUI
import Photos
import RealityKit
import ARKit

class ViewModel: ObservableObject {
    
    // MARK: - Properties
    var DEBUG_MODE: Bool = true
    
    var titleText: String = "Photo Gallery"
    @Published var photos: [NamedImage] = []
    @Published var isShowingImmersive: Bool = false
    
    // MARK: - Photo Fetching Properties
    private var fetchResult: PHFetchResult<PHAsset>!
    
    // MARK: - Immersive Photo Display
    @Published var pictureManager: PictureManager
    
    
    // MARK: - ARKit Sensing Data:
    var arkitSession = ARKitSession()
    var worldSensingAuthorizationStatus = ARKitSession.AuthorizationStatus.notDetermined
    var providersStoppedWithError = false
    
    var allRequiredAuthorizationsAreGranted: Bool {
        worldSensingAuthorizationStatus == .allowed
    }

    var allRequiredProvidersAreSupported: Bool {
        WorldTrackingProvider.isSupported
    }
    func requestWorldSensingAuthorization() async {
        let authorizationResult = await arkitSession.requestAuthorization(for: [.worldSensing])
        worldSensingAuthorizationStatus = authorizationResult[.worldSensing]!
    }
    
    func queryWorldSensingAuthorization() async {
        let authorizationResult = await arkitSession.queryAuthorization(for: [.worldSensing])
        worldSensingAuthorizationStatus = authorizationResult[.worldSensing]!
    }
    
    func monitorSessionEvents() async {
        for await event in arkitSession.events {
            switch event {
            case .dataProviderStateChanged(_, let newState, let error):
                switch newState {
                case .initialized:
                    break
                case .running:
                    break
                case .paused:
                    break
                case .stopped:
                    if let error {
                        print("An error occurred: \(error)")
                        providersStoppedWithError = true
                    }
                @unknown default:
                    break
                }
            case .authorizationChanged(let type, let status):
                print("Authorization type \(type) changed to \(status)")
                if type == .worldSensing {
                    worldSensingAuthorizationStatus = status
                }
            default:
                print("An unknown event occured \(event)")
            }
        }
    }
    
    
    
    
    // MARK: - Initialization
    @MainActor
    init() {
        pictureManager = PictureManager()
        checkPhotoLibraryPermission()
    }
}

struct NamedImage {
    public var image: UIImage
    public var name = UUID().uuidString
}
