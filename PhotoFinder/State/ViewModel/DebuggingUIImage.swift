//
//  DebuggingUIImage.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/14/24.
//

import Foundation
import SwiftUI
import UIKit

// Function to create a UIImage with a solid color
func createSolidColorImage(color: UIColor, size: CGSize) -> UIImage {
    // Begin a graphics context
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill() // Set the fill color to the specified color
    UIRectFill(CGRect(origin: .zero, size: size)) // Fill the rectangle with the color
    let image = UIGraphicsGetImageFromCurrentImageContext()! // Get the image from the context
    UIGraphicsEndImageContext() // End the graphics context
    return image
}

