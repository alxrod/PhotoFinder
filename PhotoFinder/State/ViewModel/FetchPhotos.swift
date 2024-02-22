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
    
    func getCameraRoll() -> [NamedImage] {
        var cameraRollImages: [NamedImage] = []
        for image in photos {
            if image.space == ImageSpace.cameraRoll {
                cameraRollImages.append(image)
            }
        }
        if cameraRollImages.count < self.fetchSize*2 {
            cameraRollImages += getNextCameraRollPage()
        }
        return cameraRollImages
    }
    
    func getNextCameraRollPage() -> [NamedImage] {
        let newPhotos = self.fetchPhotos(pageNumber: self.fetchPage, pageSize: self.fetchSize)
        self.fetchPage += 1
        return newPhotos
    }
    
//    func getPilePhotos() -> [NamedImage] {
//        
//    }

    // MARK: - Fetch Photos
    func fetchPhotos(pageNumber: Int, pageSize: Int) -> [NamedImage] {
        if self.DEBUG_MODE {
            var testImages: [NamedImage] = []
            for _ in 0..<pageSize {
                testImages.append(
                    NamedImage(image: createSolidColorImage(size: CGSize(width: 100, height: 100)), space: .cameraRoll)
                )
            }
            self.photos += testImages
            self.photosInView += testImages.count
            return testImages
        }

        guard let cameraRollAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject else { return [] }

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(in: cameraRollAlbum, options: fetchOptions)

        let start = pageNumber * pageSize
        let end = start + pageSize
        let count = fetchResult.count
        if start >= count {
            // Handle case where requested page is out of bounds
            return []
        }

        // Prepare a block to convert PHAsset to UIImage
        func convertAssetsToUIImages(assets: [PHAsset], completion: @escaping ([UIImage]) -> Void) {
            var images: [UIImage] = []
            var requestCount = 0 // Keep track of the number of completed requests
            let options = PHImageRequestOptions()
            options.isSynchronous = false // Set to false to allow asynchronous requests
            options.deliveryMode = .highQualityFormat // Request high-quality images
            let manager = PHImageManager.default()

            for asset in assets {
                manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (result, info) in
                    DispatchQueue.main.async {
                        if let image = result {
                            images.append(image)
                        }
                        requestCount += 1
                        if requestCount == assets.count {
                            completion(images) // Call completion handler once all requests are completed
                        }
                    }
                }
            }
        }

        // Slice the fetchResult to get only the assets for the current page
        var assetsToFetch: [PHAsset] = []
        fetchResult.enumerateObjects { asset, index, stop in
            if index >= start && index < min(end, count) {
                assetsToFetch.append(asset)
            }
        }
        

        // Convert the sliced PHAssets to UIImages
        var returnImages: [NamedImage] = []
        convertAssetsToUIImages(assets: assetsToFetch) { images in
            DispatchQueue.main.async {
                let outImages = images.map { NamedImage(image: $0, space: .cameraRoll) }
                self.photosInView += outImages.count
                self.photos += outImages
                returnImages = outImages
            }
        }
        return returnImages
        
    }
    
    // MARK: - Helper Method to Convert PHAsset to UIImage
    private func convertPHAssetToUIImage(assets: PHFetchResult<PHAsset>, completion: @escaping ([UIImage]) -> Void) {
        var images: [UIImage] = []
        let dispatchGroup = DispatchGroup()

        assets.enumerateObjects { (asset, _, _) in
            dispatchGroup.enter()
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.version = .original
            options.isSynchronous = true
//            options.deliveryMode = .highQualityFormat // Request a high-quality image
            options.isNetworkAccessAllowed = true

            manager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: options) { image, _ in
                if let image = image {
                    images.append(image)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(images)
        }
    }


}
