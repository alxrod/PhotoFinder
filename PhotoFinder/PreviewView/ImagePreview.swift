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
    @Environment(\.isHoverEffectEnabled) var isHoverEnabled
    
    public var image: NamedImage
    public var imageSize: CGFloat
    public var removeImage: (String) -> ()
    public var dragInProgress: Bool = false
    
    @State private var added: Bool = false
    @State private var isSelecting: Bool = false
    
    
    private let inFrontAdjustment: Double = 100 //To make sure the pictures come out ahead of the window itself
    
    
//  Note I should handle forced unwraps of getPhoto later here:
    init(image: NamedImage, imageSize: CGFloat, removeImage: @escaping (String) -> ()) {
        self.image = image
        self.imageSize = imageSize
        self.removeImage = removeImage
    }
    var body: some View {
        
        GeometryReader3D { proxy in
            ZStack {
                Image(uiImage: self.image.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(8)
                    .opacity(added ? 0.5 : 1)
                    .hoverEffectBorder(isHovered: $isSelecting)
                    .hoverEffect(.lift)
                    .gesture(
                        
                        SimultaneousGesture(
                        DragGesture(minimumDistance: 0).onChanged { _ in
                            self.isSelecting = true
                            if self.image.imageQuality == .low {

                            }
                        }.onEnded { _ in
                            self.isSelecting = false
                        },
                        
                        
                        DragGesture(minimumDistance: 15).onChanged { value in
                            if self.image.imageQuality == .low {
                                return
                            }
                            
                            self.isSelecting = false
                            
//                          If coming from pile, have to take it out of space to be able to move it elsewhere
                            if ImageSpace.isPile(image.space) {
                                self.model.pictureManager.removeFromPileByName(image.name, pileEntityId: image.space.id)
                            }
    
                            if let transform = proxy.transform(in: .named(ViewModel.pictureSpace)) {
                                let point = SIMD4<Double>(
                                    value.location3D.x,
                                    value.location3D.y,
                                    value.location3D.z+inFrontAdjustment,
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
                                    guard let picEntity = model.pictureManager.findPictureEntity(name: image.name) else { return }
                                    
                                    model.pictureManager.updateLoc(entity: picEntity, newPos: outPoint)
                                } else {
                                    image.space = .floating
                                    model.pictureManager.addPicture(
                                        from: image,
                                        pos: outPoint,
                                        rot: nil
                                    )
                                    added = true
                                }

                            }
                        }.onEnded { value in
                            self.removeImage(image.name)
                            
                            added = false
                            guard let picEntity = model.pictureManager.findPictureEntity(name: image.name) else { return }
                            picEntity.image.space = .floating
                            model.pictureManager.checkPictureCollisions(pictureEntity: picEntity)
                        })
                    )
            }
            .frame(width: imageSize, height: imageSize) // Ensure the ZStack has the same frame size
            .background(Color.clear) // Apply a clear background to the ZStack
            .cornerRadius(8) // Apply corner radius to ZStack to match the image
            .hoverEffect()
        }
    }
}
