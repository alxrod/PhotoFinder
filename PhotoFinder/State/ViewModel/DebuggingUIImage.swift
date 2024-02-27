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
func createSolidColorImage(size: CGSize) -> UIImage {
    // Begin a graphics context
//    let red = CGFloat.random(in: 0...1)
//    let green = CGFloat.random(in: 0...1)
//    let blue = CGFloat.random(in: 0...1)
//    let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    let color: UIColor = .gray
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill() // Set the fill color to the specified color
    UIRectFill(CGRect(origin: .zero, size: size)) // Fill the rectangle with the color
    let image = UIGraphicsGetImageFromCurrentImageContext()! // Get the image from the context
    UIGraphicsEndImageContext() // End the graphics context
    return image
}

