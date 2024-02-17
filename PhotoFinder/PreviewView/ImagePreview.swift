//
//  ImagePreview.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/15/24.
//

import Foundation
import SwiftUI
import RealityKit
import simd

struct ImagePreview: View {
    @EnvironmentObject private var model: ViewModel
    @Environment(\.physicalMetrics) var physicalMetrics
    
    public var image: NamedImage
    public var imageSize: CGFloat
    
    @State private var added: Bool = false
    @State private var removedFromView: Bool = false
    
    var body: some View {
        GeometryReader3D { proxy in
            ZStack {
                Image(uiImage: image.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(8)
                    .gesture(DragGesture().onChanged { value in
                        if removedFromView {
                            return
                        }
                        if let transform = proxy.transform(in: .named(Module.active.name)) {
                            let point = SIMD4<Double>(
                                value.location3D.x,
                                value.location3D.y,
                                value.location3D.z,
                                1
                            )
                            // Apply the affine transformation
                            let tP = transform.matrix * point
                            
                            // Extract the x, y, z components from the transformed point
                            
                            var outPoint = SIMD3<Float>(physicalMetrics.convert(Point3D(
                                x: tP.x,
                                y: tP.y,
                                z: tP.z), to: .meters))
                            
                            outPoint.x = outPoint.x / Float(transform.scale.width)
                            outPoint.y = outPoint.y / Float(-1*transform.scale.height)
                            outPoint.z = outPoint.z / Float(transform.scale.depth)
                            
                            if added {
                                model.pictureManager.updatePictureLoc(name: image.name, to: outPoint)
                            } else {
                                model.pictureManager.addPicture(
                                    from: image,
                                    pos: outPoint,
                                    rot: nil
                                )
                                added = true
                            }

                        }
                    }.onEnded { value in
                        removedFromView = true
                    })
            }
        }
    }
}



//                                            .onTapGesture {
//                                                print(proxy.frame(in: .local))
//                                                print(proxy.frame(in: .named(Module.active.name)))
//                                                print(proxy.size)
//                                                if let transform = proxy.transform(in: .named(Module.active.name)) {
//                                                    print("Converted coords to \(transform.scale) \(transform.translation) \(transform.rotation)")
//
//                                                    let phys_trans = physicalMetrics.convert(transform.translation, to: .meters)
//                                                    let translation = SIMD3<Float>(
//                                                        Float(phys_trans.x / transform.scale.width),
//                                                        Float(phys_trans.y / (-1*transform.scale.height)),
//                                                        Float(phys_trans.z / transform.scale.depth))
//
//                                                    model.pictureManager.addPicture(
//                                                        from: model.photos[index],
//                                                        pos: translation,
//                                                        rot: transform.rotation != nil ? simd_quatf(transform.rotation!) : nil
//                                                    )
//                                                }
//                                            }
