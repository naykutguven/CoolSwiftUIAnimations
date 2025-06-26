//
//  Item.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 26.06.25.
//

import SwiftUI

struct ItemModel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}
