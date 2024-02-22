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
    
    public var images: [NamedImage]
    var cameraRollMode: Bool
    public var removeImage: (String) -> ()
    public var requestMorePhotos: () -> ()
    
    
    @State private var pageLimit = 30
    @State private var currentPage = 0
    
    private var maxPage: Int {
        images.count / pageLimit + (images.count % pageLimit > 0 ? 1 : 0) - 1
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
//                ScrollView {
                    let columns = Array(repeating: GridItem(.flexible()), count: Int(geometry.size.width / CGFloat(spacing + imageSize)))
                
                    

                    LazyVGrid(columns: columns) {
                        ForEach(currentPageImages.indices, id: \.self) { index in
                            VStack {
                                ImagePreview(
                                    image: currentPageImages[index],
                                    imageSize: imageSize,
                                    removeImage: removeImage
                                ).environmentObject(model)
                            }.frame(width: imageSize, height: imageSize)
                        }
                    }.onChange(of: geometry.size) {
                        let columnsCount = Int((geometry.size.width + spacing) / (imageSize + spacing))
                        let rowsCount = Int(geometry.size.height / (imageSize + spacing))
                        
                        let newLim = columnsCount*rowsCount
                        if newLim > images.count && cameraRollMode {
                            requestMorePhotos()
                        }
                        pageLimit = newLim
                    }
//                }
            }
            .padding()
            
            HStack {
                Button("Previous") {
                    if currentPage > 0 { currentPage -= 1 }
                }
                .disabled(currentPage <= 0)
                
                Spacer()
                
                Text("Page \(currentPage + 1) \(cameraRollMode ? "" : " of \(maxPage + 1)")")
                
                Spacer()
                
                Button("Next") {
                    if currentPage < maxPage || cameraRollMode { currentPage += 1 }
                    if images.count - (currentPage*pageLimit) <= pageLimit {
                        requestMorePhotos()
                    }
                }
                .disabled(currentPage >= maxPage && !cameraRollMode)
            }
            .padding()
        }
    }
    
    private var currentPageImages: [NamedImage] {
        let startIndex = currentPage * pageLimit
        let endIndex = min(startIndex + pageLimit, images.count)
        return Array(images[startIndex..<endIndex])
    }
}

