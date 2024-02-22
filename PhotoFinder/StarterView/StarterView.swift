//
//  ContentView.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct StarterView: View {
    
    @EnvironmentObject private var model: ViewModel

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var navigateToNextView = false
    
    private let instructions = [
        "Drag images from the window anywhere in 3D space",
        "Place them ontop of eachother to form piles",
        "Tap on a pile to view it's content or remove any you don't want"
    ]

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text(model.titleText).font(.extraLargeTitle2)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(instructions, id: \.self) { item in
                    HStack {
                        Text("•") // Bullet symbol
                            .font(.system(size: 22)) // Adjust the size of the bullet symbol as needed
                        Text(item)
                            .font(.system(size: 18)) // Adjust text size as needed
                    }.padding(.vertical, 5)
                }
            }.frame(maxWidth: 300)
                .padding()
            
            Spacer()
            
            NavigationLink(value: Module.cameraRoll) {
                Text("Start Sorting")
            }
            
            Spacer()
        }
        .onChange(of: scenePhase, initial: true) {
            print("HomeView scene phase: \(scenePhase)")
            if scenePhase == .active {
                Task {
                    // Check whether authorization has changed when the user brings the app to the foreground.
                    await model.queryWorldSensingAuthorization()
                }
            } else {
                // Leave the immersive space if this view is no longer active;
                // the controls in this view pair up with the immersive space to drive the placement experience.
                if model.isShowingImmersive {
                    Task {
                        await dismissImmersiveSpace()
                        model.isShowingImmersive = false
                    }
                }
            }
        }
        .onChange(of: model.providersStoppedWithError, { _, providersStoppedWithError in
            // Immediately close the immersive space if there was an error.
            if providersStoppedWithError {
                if model.isShowingImmersive {
                    Task {
                        await dismissImmersiveSpace()
                        model.isShowingImmersive = false
                        //                            model.didLeaveImmersiveSpace()
                    }
                }
                
                model.providersStoppedWithError = false
            }
        })
        .task {
            // Request authorization before the user attempts to open the immersive space;
            // this gives the app the opportunity to respond gracefully if authorization isn’t granted.
            if model.allRequiredProvidersAreSupported {
                await model.requestWorldSensingAuthorization()
            }
        }
        .task {
            // Monitors changes in authorization. For example, the user may revoke authorization in Settings.
            await model.monitorSessionEvents()
        }
        .padding(70)
    }
    
}

#Preview(windowStyle: .automatic) {
    StarterView()
}
