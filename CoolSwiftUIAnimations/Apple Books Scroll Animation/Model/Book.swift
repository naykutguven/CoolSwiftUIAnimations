//
//  Book.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 28.06.25.
//

import SwiftUI

struct Book: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let rating: String
    let thumbnail: String
    let color: Color
}

extension Book {
    static let sampleBooks: [Book] = [
        Book(
            title: "Thinking in SwiftUI",
            author: "Chris Eidhof & Florian Kugler",
            rating: "4.5",
            thumbnail: "boxPupper",
            color: Color.yellow
        ),
        Book(
            title: "In Praise of Idleness",
            author: "Bertrand Russell",
            rating: "4.8",
            thumbnail: "wellbehavedPupper",
            color: Color.pink
        ),
    ]
}

