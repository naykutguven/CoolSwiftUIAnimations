//
//  InfiniteCarousel.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 05.07.25.
//

import SwiftUI

struct InfiniteCarousel<Content: View>: View {
    @ViewBuilder var content: Content

    // This needs to be an optional Int so we can pass it to the scrollPosition modifier.
    @State private var scrollPosition: Int?
    @State private var isScrolling = false

    var body: some View {
        GeometryReader {
            let size = $0.size

            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    Group(subviews: content) { collection in
                        if let last = collection.last {
                            last
                                .frame(width: size.width, height: size.height)
                                .id(-1)
                                .onChange(of: isScrolling) { _, newValue in
                                    // if scrolling stopped at this item (visually the last item),
                                    if !newValue && scrollPosition == -1 {
                                        // move the scroll position to the actual last item
                                        // without animation
                                        scrollPosition = collection.count - 1
                                    }
                                }
                        }

                        ForEach(collection.indices, id: \.self) { index in
                            collection[index]
                                .frame(width: size.width, height: size.height)
                                .id(index)
                        }

                        if let first = collection.first {
                            first
                                .frame(width: size.width, height: size.height)
                                .id(collection.count)
                                .onChange(of: isScrolling) { _, newValue in
                                    // if scrolling stopped at this item (visually the first item),
                                    if !newValue && scrollPosition == collection.count {
                                        // move the scroll position to the actual first item
                                        // without animation
                                        scrollPosition = 0
                                    }
                                }
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                geo.contentOffset.x
            }, action: { oldValue, newValue in
                print("Content Offset: \(newValue)")
            })
            .onScrollPhaseChange { _, newPhase in
                print("Carousel Size: \(size)")
                isScrolling = newPhase.isScrolling
            }
            .scrollPosition(id: $scrollPosition)
            // This infinite carousel implementation only works with paging behavior.
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.never)
            // Resetting the scroll position to the first item when the view appears
            // because we added the last item in the beginning and the first item at the end.
            .onAppear {
                scrollPosition = 0
            }
        }
    }
}

private struct InfiniteCarouselContentView: View {
    let items = ItemModel.sceneSamples
    var body: some View {
        NavigationStack {
            VStack {
                InfiniteCarousel {
                    ForEach(items) { item in
                        CardView(imageName: item.imageName)
                            .padding(.horizontal, 15)
                    }
                }
            }
            .navigationTitle("Infinite Carousel")
        }
    }
}

#Preview {
    InfiniteCarouselContentView()
}
