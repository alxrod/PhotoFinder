//
//  Module.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import Foundation


enum Module: Hashable, Identifiable, CaseIterable, Equatable {
    
    case launcher
    case cameraRoll
    case pile(pileName: String, pileId: String)

    var id: String {
        switch self {
        case .launcher:
            return "launcher"
        case .cameraRoll:
            return "cameraRoll"
        case .pile(let pileName, let pileId):
            return pileId
        }
    }


    var name: String {
        switch self {
        case .launcher:
            return "Launcher"
        case .cameraRoll:
            return "Camera Roll"
        case .pile(let pileName, let pileId):
            return pileName.capitalized
        }
    }
    

    // Implementation for CaseIterable
    static var allCases: [Module] {
        // Since `pile` requires a specific id, it's not included in allCases.
        // You might need to handle cases with associated values differently.
        [.launcher, .cameraRoll]
    }

    // Implementation for Equatable
    static func isPile(_ m: Module) -> Bool{
        switch m {
        case .pile(let pileName, let pileId):
            return true
        default:
            return false
        }
    }
    
    static func ==(lhs: Module, rhs: Module) -> Bool {
        switch (lhs, rhs) {
        case (.launcher, .launcher), (.cameraRoll, .cameraRoll):
            return true
        case (.pile(let pileName1, let pileId1), .pile(let pileName2, let pileId2)):
            return pileId1 == pileId2
        default:
            return false
        }
    }
}
