//
//  Module.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/11/24.
//

import Foundation

///// A description of the modules that the app can present.
enum Module: String, Identifiable, CaseIterable, Equatable {
    case launch,active
    var id: Self { self }
    var name: String { rawValue.capitalized }
    
    var callToAction: String {
        switch self {
        case .launch: "Start Sorting"
        case .active: "Stop Sorting"
        }
    }
}
