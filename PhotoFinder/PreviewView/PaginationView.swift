//
//  PaginationView.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/22/24.
//

import Foundation
import SwiftUI

struct PaginationView: View {
    var images: [NamedImage]
    var removeImage: (String) -> Void
    let pageLimit: Int
    
    private let spacing = 20.0
    private let imageSize = 100.0
    
    @State private var currentPage = 0
    
    private var maxPage: Int {
        images.count / pageLimit + (images.count % pageLimit > 0 ? 1 : 0) - 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            //                ScrollView {
            let columns = Array(repeating: GridItem(.flexible()), count: Int(geometry.size.width / CGFloat(spacing + imageSize)))
            
            VStack {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(currentPageImages.indices, id: \.self) { index in
                        ImagePreview(image: currentPageImages[index], imageSize: imageSize, removeImage: removeImage)
                    }
                }.frame(height: .infinity)
                
               
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var currentPageImages: [NamedImage] {
        let startIndex = currentPage * pageLimit
        let endIndex = min(startIndex + pageLimit, images.count)
        return Array(images[startIndex..<endIndex])
    }
}
