//
//  PhotoFinderApp.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import SwiftUI

@main
struct PhotoFinderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
