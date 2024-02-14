//
//  PreviewView.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import Foundation
import SwiftUI

struct PreviewView: View {
    @EnvironmentObject private var model: ViewModel
    private let spacing = 20.0
    private let imageSize = 100.0
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    let columns = Array(repeating: GridItem(.flexible()), count: Int(geometry.size.width / CGFloat(spacing + imageSize)))
                    
                    LazyVGrid(columns: columns) {
                        ForEach(model.photos.indices, id: \.self) { index in
                            GeometryReader3D { proxy in
                                Image(uiImage: model.photos[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imageSize, height: imageSize)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        if #available(visionOS 1.1, *) {
                                            if let translation = proxy.transform(in: .immersiveSpace)?.translation {
                                                print("Converted coords to \(translation)")
                                                model.pictureManager.addPicture(from: model.photos[index], withPos: SIMD3(translation))
                                            }
                                        } else {
                                            // Fallback on earlier versions
                                            print("YOUR VERSION IS TOO OLD")
                                        }
                                        
                                    }
                            }
                            .frame(width: imageSize, height: imageSize) // Ensure the GeometryReader is confined to the image size
                        }
                    }
                }
            }
            
            .padding()
        }
        .onAppear {
            model.checkPhotoLibraryPermission()
            Task {
                await model.fetchPhotos()
            }
        }
    }
}

