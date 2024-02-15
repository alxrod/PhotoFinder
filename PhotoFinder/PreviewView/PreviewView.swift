//
//  PreviewView.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import Foundation
import SwiftUI
import RealityKit

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
                                GeometryReader3D { proxy in
                                    ZStack {
                                        
                                        Image(uiImage: model.photos[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: imageSize, height: imageSize)
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                if #available(visionOS 1.1, *) {
                                                    print(proxy.frame(in: .local))
                                                    print(proxy.frame(in: .immersiveSpace))
                                                    print(proxy.size)
                                                    if let transform = proxy.transform(in: .immersiveSpace) {
                                                        print("Converted coords to \(transform.scale) \(transform.translation) \(transform.rotation)")
                                                        
                                                        let phys_trans = physicalMetrics.convert(transform.translation, to: .meters)
                                                        let translation = SIMD3<Float>(
                                                            Float(phys_trans.x / transform.scale.width),
                                                            Float(phys_trans.y / (-1*transform.scale.height)),
                                                            Float(phys_trans.z / transform.scale.depth))
                                                        
                                                        model.pictureManager.addPicture(
                                                            from: model.photos[index],
                                                            pos: translation,
                                                            rot: transform.rotation != nil ? simd_quatf(transform.rotation!) : nil
                                                        )
                                                    }
                                                } else {
                                                    // Fallback on earlier versions
                                                    print("YOUR VERSION IS TOO OLD")
                                                }
                                            }
//                                        ImagePreview(image: model.photos[index], imageSize: imageSize)
//                                            .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { value in
//                                                if #available(visionOS 1.1, *) {
//                                                    if let immersivePoint = proxy.transform(in: .immersiveSpace) {
//                                                        print("REGISTERING TAP")
//                                                        let final_point = value.convert(immersivePoint, from: .immersiveSpace, to: model.pictureManager.rootEntity)
//                                                        
//                                                        model.pictureManager.addPicture(from: model.photos[index], withPos: Point3D(final_point.translation))
//                                                    }
//                                                }
//                                            })
                                        //
                                    }
                                }
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

