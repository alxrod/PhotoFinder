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
    public func fetchPhotos() {
        // Fetch the default camera roll album
        let cameraRollAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 10 // Adjust as needed

        if let album = cameraRollAlbum {
            let fetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions)

            convertPHAssetToUIImage(assets: fetchResult) { images in
                DispatchQueue.main.async {
                    self.photos = images
                }
            }
        }
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
