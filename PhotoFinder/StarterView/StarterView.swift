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

    var body: some View {
        GeometryReader3D { proxy3D in
            VStack {
                Text(model.titleText).font(.title)
                ImmersiveViewToggle()
                PreviewView().environmentObject(model)
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
//                            model.didLeaveImmersiveSpace()
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
            .onAppear {
            }
            
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    StarterView()
}
