//
//  FetchPhotos.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/12/24.
//

import SwiftUI
import Photos

extension ViewModel {


    // MARK: - Photo Library Access
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            // Request permission
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                if newStatus == .authorized {
                    print("Photos Authorized")
                } else {
                    self.titleText = "Permission Denied"
                }
            }
        case .authorized:
            print("Photos Authorized")
        default:
            titleText = "Permission Denied"
        }
    }
    
    
    // MARK: - Fetch Photos
    func getCameraRoll() -> [NamedImage] {
        var cameraRollImages: [NamedImage] = []
        print("Pulling from \(self.photos.count)")
        self.photosQueue.sync {
            for image in self.photos {
                if image.space == ImageSpace.cameraRoll {
                    cameraRollImages.append(image)
                }
            }
        }
        print("Returning a total of \(cameraRollImages)")
        
        return cameraRollImages
    }
    

    
    func fetchPhotos() {
        if self.DEBUG_MODE {
            var testImages: [NamedImage] = []
            for _ in 0..<self.fetchSize {
                testImages.append(
                    NamedImage(image: createSolidColorImage(size: CGSize(width: 100, height: 100)), quality: .high, space: .cameraRoll)
                )
            }
            self.photos += testImages
        }
        
        
        // Step 1: get the assets form our photo libary, reverse sorted by creation date.
        guard let cameraRollAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject else { return }

        //Thing to Optimize: only gettign assets we haven't seen
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(in: cameraRollAlbum, options: fetchOptions)
        print("Assets requested \(fetchResult.count)")
        
//      Select a fetchSize from all of the assets, then increment offset by the amount we are about to request for
        let start = self.fetchOffset
        let end = start + self.fetchSize
        let count = fetchResult.count
        if start >= count {
            // Handle case where requested page is out of bounds
            return
        }
        
        // Slice the fetchResult to get only the assets for the current page
        var assetsToFetch: [PHAsset] = []
        fetchResult.enumerateObjects { asset, index, stop in
            if index >= start && index < min(end, count) {
               assetsToFetch.append(asset)
            }
        }
        self.fetchOffset += assetsToFetch.count
        
        print("Fetching \(assetsToFetch.count) photos at offset \(self.fetchOffset) with status \(PHPhotoLibrary.authorizationStatus())" )

        // Convert the sliced PHAssets to UIImages
        convertAssetsToUIImages(assets: assetsToFetch) {
            // TODO: Final completion, should only get called once
        }
       
   }
    
    func convertAssetsToUIImages(assets: [PHAsset], completion: @escaping () -> Void) {
        var requestCount = 0 // Keep track of the number of completed requests
        let options = PHImageRequestOptions()
        options.isSynchronous = false // Set to false to allow asynchronous requests
        options.isNetworkAccessAllowed = true
        let manager = PHImageManager.default()

        for asset in assets {
            options.deliveryMode = .fastFormat
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (result, info) in
                self.photosQueue.async { //protects serial writing to the images array
                    if let image = result {
                        let image = NamedImage(image: image, quality: .low, space: .cameraRoll)
                        DispatchQueue.main.sync { //Should only modify photos in main thread
                            self.photos.append(image)
                        }
                        self.requestHighRes(for: asset, to: image, manager: manager, options: options)
                    }
                    requestCount += 1
                    if requestCount == assets.count {
                        DispatchQueue.main.async {
                            completion() // Call completion handler once all requests are completed
                        }
                    }
                }
            }
        }
    }
       
    func requestHighRes(for asset: PHAsset, to namedImage: NamedImage, manager: PHImageManager, options: PHImageRequestOptions) {
        options.deliveryMode = .highQualityFormat
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (highQualityResult, _) in
            if let highQualityImage = highQualityResult {
                self.photosQueue.async {
                    DispatchQueue.main.sync { // want to only modify in main threat, need it to block till end of photosQueue async so modifications only happen once per thread
                        if let index = self.photos.firstIndex(where: { $0.name == namedImage.name }) {
                            self.photos[index].image = highQualityImage
                            self.photos[index].imageQuality = .high
                        }
                    }
                }
            }
        }
    }
}

extension PHImageManager {
    func requestImageAsync(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) async -> UIImage? {
        await withCheckedContinuation { continuation in
            self.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
