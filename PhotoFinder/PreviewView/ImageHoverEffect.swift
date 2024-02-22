//
//  ImageHoverEffect.swift
//  PhotoFinder
//
//  Created by Alex Rodriguez on 2/21/24.
//

import SwiftUI

struct HoverEffectModifier: ViewModifier {
    @Binding var isHovered: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: isHovered ? 4 : 0)
            )
    }
}

extension View {
    func hoverEffectBorder(isHovered: Binding<Bool>) -> some View {
        self.modifier(HoverEffectModifier(isHovered: isHovered))
    }
}
