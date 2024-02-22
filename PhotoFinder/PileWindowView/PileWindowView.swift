//
//  PileWindowView.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/21/24.
//

import SwiftUI

struct PileWindowView: View {
    
    @EnvironmentObject private var model: ViewModel

    var module: Module
    
    @State private var editableName: String
    @State private var images: [NamedImage]
    
    init(module: Module) {
        self.module = module
        _editableName = State(initialValue: module.name)
        images = []
    }
    
    var body: some View {

        VStack(alignment: .leading) {
            HStack {
                if module == .cameraRoll {
                    Text(module.name)
                        .font(.extraLargeTitle2)
                        .padding(.horizontal, 30)
                } else {
                    TextField("", text: $editableName)
                        .font(.extraLargeTitle2)
                        .padding(.horizontal, 30)
                        .submitLabel(.done)
                        .onSubmit {
                            if model.pictureManager.selectedPile?.name != editableName {
                                model.pictureManager.selectedPile?.rename(to: editableName)
                            }
                        }
                    Spacer()
                    Button(action: {
                        self.editableName = "" // Clear the text field
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 30)
                }
            }
            PreviewView(images: images, cameraRollMode: module == .cameraRoll) { name in
                let idx = images.firstIndex { $0.name == name }
                guard let idx = idx else {return}
                images.remove(at: idx)
            } requestMorePhotos: {
                if module == .cameraRoll {
                    images += model.getNextCameraRollPage()
                }
            }.environmentObject(model)
        }
        .onChange(of: module) { _, path in
            editableName = module.name
            if Module.isPile(module) {
                images = model.pictureManager.getPileIdPics(module.id)
            } else {
                images = model.getCameraRoll()
            }
            print("COMPLETED HERE: \(images)")
        }
        .onAppear() {
            if Module.isPile(module) {
                images = model.pictureManager.getPileIdPics(module.id)
            } else {
                images = model.getCameraRoll()
            }
        }
        .padding(.horizontal, 50)
        .navigationTitle(module == Module.cameraRoll ? "Stop Sorting" : "Camera Roll")
        // Sets the navigation bar title for this view
    }
}
