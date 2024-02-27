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
    
    func transferImageToInSpace(name: String) {
        let index = self.cameraRoll.firstIndex{ $0.name == name }
        guard let index = index else{ return }
        let image = self.cameraRoll.remove(at: index)
        self.inSpace.append(image)
    }
    
    func cacheFetchResults() {
        guard let cameraRollAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject else { return }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(in: cameraRollAlbum, options: fetchOptions)
        
        self.unloadedAssetQueue = []
        fetchResult.enumerateObjects { (asset, _, _) in
            self.unloadedAssetQueue.append(asset)
        }
        print("Unloaded asset queue is now \(self.unloadedAssetQueue.count)")
        
    }
    
    func generateNamedImages(until end: Int) {
        if end > unloadedAssetQueue.count { return }
        let numImages = min(end,unloadedAssetQueue.count)
        print("Adding a total of \(numImages) elements to camera roll")
        for _ in 0..<numImages {
            let asset = unloadedAssetQueue.removeFirst()
            self.cameraRoll.append(NamedImage(
                asset: asset,
                image: nil,
                quality: .empty,
                space: .cameraRoll))
        }
    }
    
//  The algorithm is as follows:
    // Step 1) render low res images for current page if it doens't exist
    // Step 2) render low res images for the page after
    // Step 3) render high res images for the current page
    // Step 4) render high res pictures for the page before and after
    // Step 5) empty photos from 4 pages behind or 4 pages in front
    func getCameraRollPage(start: Int, initialEnd: Int) {
        if start < 0 || start > initialEnd {
            return
        }
        
        let pageSize = initialEnd-start
        if initialEnd+pageSize > self.cameraRoll.count { //Want to generate one extra page of images if needed
            generateNamedImages(until: initialEnd+pageSize)
        }
        
        var end = initialEnd
        if self.cameraRoll.count < end {
            end = self.cameraRoll.count
        }
        
        // Low quality render first pass
        print("End case is \(end+pageSize) but cam count is \(self.cameraRoll.count)")
        renderImageSet(images: self.cameraRoll[start..<end], quality: .low)
        renderImageSet(images: self.cameraRoll[end..<end+pageSize], quality: .low)
        
        // High quality render second pass
        renderImageSet(images: self.cameraRoll[start..<end], quality: .high)
        renderImageSet(images: self.cameraRoll[end..<end+pageSize], quality: .high)
        
        //Remove all images of before 4 pages or after 4 pages
        let removalLowerBound = start-(pageSize*4)
        let removalUpperBound = end+(pageSize*4)
        if removalLowerBound > 0 {
            renderImageSet(images: self.cameraRoll[0..<removalLowerBound], quality: .empty)
        }
        if removalUpperBound < self.cameraRoll.count{
            renderImageSet(images: self.cameraRoll[removalUpperBound..<self.cameraRoll.count], quality: .empty)
        }
   }
    
    
    
    func renderImageSet(images: ArraySlice<NamedImage>, quality: ImageQuality) {
        if quality == .empty { // Empty out photos from previous pages, but ONLY if they are in the camera roll space
            for img in images {
                if img.space == .cameraRoll {
                    img.imageQuality = .empty
                    img.uiImage = nil
                }
            }
            return
        }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false // Set to false to allow asynchronous requests
        options.isNetworkAccessAllowed = true
        
        options.deliveryMode = .fastFormat
        if quality == .high {
            options.deliveryMode = .highQualityFormat
        }
        
        for namedImage in images {
            if namedImage.imageQuality.rawValue >= quality.rawValue { //If the photo is already loaded at the desired quality or better, don't make a call to load to write it
                continue
            }
            manager.requestImage(for: namedImage.asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (result, info) in
                self.photosQueue.async { //protects serial writing to the images array
                    if let uiImage = result {
                        DispatchQueue.main.sync { //Should only modify photos in main thread
                            namedImage.imageQuality = quality
                            namedImage.uiImage = uiImage
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
