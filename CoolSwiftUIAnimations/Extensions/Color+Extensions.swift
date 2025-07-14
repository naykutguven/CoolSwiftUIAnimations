//
//  Color+Extensions.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 14.07.25.
//

import SwiftUI

extension Color {
    static var random: Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(red: red, green: green, blue: blue)
    }

    static var randomPastel: Color {
        let hue = Double.random(in: 0...1)
        let saturation = Double.random(in: 0.5...1)
        let brightness = Double.random(in: 0.7...1)
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    static var randomSystem: Color {
        let systemColors: [Color] = [
            .red, .green, .blue, .yellow, .orange, .purple, .pink,
            .teal, .mint, .cyan, .indigo,
            .black, .white, .gray, .brown
        ]
        return systemColors.randomElement() ?? .black
    }
}
