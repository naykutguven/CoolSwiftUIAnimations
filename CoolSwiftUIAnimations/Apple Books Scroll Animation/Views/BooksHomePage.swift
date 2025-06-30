//
//  BooksHomePage.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 28.06.25.
//

import SwiftUI

struct BooksHomePage: View {
    // These need to match the type of Book.id
    @State private var activeID: UUID? = Book.sampleBooks.first?.id
    @State private var scrollPosition: ScrollPosition = .init(idType: UUID.self)
    @State private var isAnyPageScrolled: Bool = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 4) {
                    ForEach(Book.sampleBooks) { book in
                        BookCardView(book: book, size: proxy.size) { isPageScrolled in
                            isAnyPageScrolled = isPageScrolled
                        }
                        .frame(width: proxy.size.width - 30)
                        .zIndex(activeID == book.id ? 1000 : 0)
                    }
                }
                .scrollTargetLayout()
            }
            .safeAreaPadding(.horizontal, 15)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition($scrollPosition)
            .scrollDisabled(isAnyPageScrolled)
            .onChange(of: scrollPosition.viewID(type: UUID.self)) { oldValue, newValue in
                activeID = newValue
            }
        }
    }
}

#Preview {
    BooksHomePage()
}
