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
    
    
    // MARK: - Navigation
    @Published var navigationPath: [Module] = []
    
    // MARK: - Properties
    var DEBUG_MODE: Bool = false
    
    var titleText: String = "Photo Gallery"
    
    
    @Published var isShowingImmersive: Bool = false
    

    // MARK: - Photo Fetching Properties
    @Published var photos: [NamedImage] = []
    let photosQueue = DispatchQueue(label: "com.photofinder.photosQueue")
    public var fetchOffset: Int = 0
    public var fetchSize: Int = 30
    
    // MARK: - Immersive Photo Display
    static let pictureSpace: String = "SortingImmersiveSpace"
    
    @Published var pictureManager: PictureManager
    
    func getPhoto(_ name: String) -> NamedImage? {
        return photos.first{ image in
            return image.name == name
        }
    }

    
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
    
    func selectPile(_ pileEntity: PileEntity) {
        self.pictureManager.selectPile(pileEntity)
        
        let newView = Module.pile(pileName: pileEntity.pileName, pileId: pileEntity.pileId)
        let pathCount = self.navigationPath.count
        if pathCount > 0 && Module.isPile(self.navigationPath[pathCount-1]) {
            let oldView = self.navigationPath.popLast()
        }
        self.navigationPath.append(newView)
        print(self.navigationPath)
    }
    
    
    
    // MARK: - Initialization
    @MainActor
    init() {
        pictureManager = PictureManager()
        checkPhotoLibraryPermission()
        Task { //Preload photos
            fetchPhotos()
            fetchPhotos()
        }
        
    }
}

class NamedImage {
    public var image: UIImage
    public var imageQuality: ImageQuality
    public var space: ImageSpace
    public var name = UUID().uuidString
    
    
    init(image: UIImage, quality: ImageQuality, space: ImageSpace, name: String = UUID().uuidString) {
        self.image = image
        self.imageQuality = quality
        self.space = space
        self.name = name
    }
}

enum ImageQuality: Int {
    case low = 0
    case high = 1
}
enum ImageSpace: Hashable, Identifiable, Equatable {
    var id: String {
        switch self {
        case .floating:
            return "floating"
        case .cameraRoll:
            return "cameraRoll"
        case .pile(let pileId):
            return pileId
        }
    }
    
    static func isPile(_ s: ImageSpace) -> Bool{
        switch s {
        case .pile(let pileId):
            return true
        default:
            return false
        }
    }

    case floating
    case cameraRoll
    case pile(pileId: String)
}
