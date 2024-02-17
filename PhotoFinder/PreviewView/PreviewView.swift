//
//  PreviewView.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import Foundation
import SwiftUI
import RealityKit
import simd

struct PreviewView: View {
    @EnvironmentObject private var model: ViewModel
    @Environment(\.physicalMetrics) var physicalMetrics
    
    private let spacing = 20.0
    private let imageSize = 100.0
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
//                ScrollView {
                    let columns = Array(repeating: GridItem(.flexible()), count: Int(geometry.size.width / CGFloat(spacing + imageSize)))

                    LazyVGrid(columns: columns) {
                        ForEach(model.photos.indices, id: \.self) { index in
                            VStack {
                                ImagePreview(image: model.photos[index], imageSize: imageSize).environmentObject(model)
                            }.frame(width: imageSize, height: imageSize)
                        }
                    }
//                }
            }
            .padding()
            .onAppear {
                model.checkPhotoLibraryPermission()
                Task {
                    model.fetchPhotos()
                }
            }
        }
//        if model.photos.count > 0 {
//            ImagePreview(image: model.photos[0], imageSize: imageSize)
//        } else {
//            Text("Loading")
//                .onAppear {
//                    model.checkPhotoLibraryPermission()
//                    Task {
//                        model.fetchPhotos()
//                    }
//                }
//        }
    }
}

