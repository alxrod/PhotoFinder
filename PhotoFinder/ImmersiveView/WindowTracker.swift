//
//  ImmersiveViewCoordTracker.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/12/24.
//

import SwiftUI
import RealityKit

//struct WindowTracker: View {
//    // State to track the entity's position
//    @State private var entityPosition: SIMD3<Float> = .zero
//
//    var body: some View {
//        VStack {
//            Text("Entity Position: \(entityPosition.description)")
//                .padding()
//            RealityView { content in
//
//                let anchor = AnchorEntity()
//                
//                // Example empty entity
//                let emptyEntity = Entity()
//                anchor.addChild(emptyEntity)
//                
//                // Optionally, you can update entityPosition based on some condition or input
//                // For demonstration, we just assign the initial position of the empty entity
//                content.add(anchor)
//                DispatchQueue.main.async {
//                    self.entityPosition = content.convert(emptyEntity.position, from: content, to: <#T##RealityCoordinateSpace#>)
//                }
//                
//            }
//        }
//    }
//}
