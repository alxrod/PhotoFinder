//
//  CameraRollWindowView.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/26/24.
//

import Foundation
import SwiftUI

import SwiftUI

struct CameraRollWindowView: View {
    
    @EnvironmentObject private var model: ViewModel

    var module: Module
    let defaultPageSize = 30

    init(module: Module) {
        self.module = module
    }
    
    var body: some View {

        VStack(alignment: .leading) {
            HStack {
                Text(module.name)
                .font(.extraLargeTitle2)
                .padding(.horizontal, 30)
            }
            
            PreviewView(images: model.cameraRoll, cameraRollMode: true) { _ in
//             Not needed
            } requestPhotoRange: { start, end in
                print("Querying page from \(start) to \(end)")
                model.getCameraRollPage(start: start, initialEnd: end)
            }.environmentObject(model)
            
        }
        .onAppear() {
            model.getCameraRollPage(start: 0, initialEnd: defaultPageSize)
        }
        .padding(.horizontal, 50)
        .navigationTitle("Stop Sorting")
        // Sets the navigation bar title for this view
    }
}
