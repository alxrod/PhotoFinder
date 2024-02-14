//
//  ViewModel.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import SwiftUI
import Photos
import RealityKit

class ViewModel: ObservableObject {
    
    // MARK: - Properties
    var titleText: String = "Photo Gallery"
    @Published var photos: [UIImage] = []
    @Published var isShowingImmersive: Bool = false
    
    // MARK: - Photo Fetching Properties
    private var fetchResult: PHFetchResult<PHAsset>!
    
    // MARK: - Immersive Photo Display
    @Published var pictureManager: PictureManager = PictureManager()

    
    // MARK: - Initialization
    init() {
        checkPhotoLibraryPermission()
    }
}
