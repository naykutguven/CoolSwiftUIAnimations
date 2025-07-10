//
//  ParallaxCarousel.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 09.07.25.
//

import SwiftUI

struct ParallaxCarousel: View {
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(ItemModel.dogSamples) { item in
                        GeometryReader { proxy in
                            let cardSize = proxy.size
                            // Parallax Effect 1
//                            let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX - 30

                            // Parallax Effect 2
                            let minX = min(
                                ((proxy.frame(in: .scrollView(axis: .horizontal)).minX - 30) * 1.4),
                                proxy.size.width * 1.4
                            )

                            Image(item.imageName)
                                .resizable()
                                .scaledToFill()
                                // Instead of adding another frame (2.5x), we can just scale
                                .scaleEffect(1.4)
                                .offset(x: -minX)
                                // The pictures must be wide enough for this to look good.
//                                .frame(width: proxy.size.width * 2.5)
                                .frame(width: cardSize.width, height: cardSize.height)
//                                .border(.blue)
                                .clipShape(.rect(cornerRadius: 15))
                                .shadow(radius: 8, x: 5, y: 10)
                        }
                        .frame(width: size.width - 60, height: size.height - 50)
//                        .border(.red)
                        .scrollTransition(.interactive, axis: .horizontal) { context, phase in
                            context
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 30)
                .frame(height: size.height, alignment: .top)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        }
        .frame(height: 500)
        .padding(.horizontal, -15)
        .padding(.top, 10)
    }
}
private struct ParallaxCarouselContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ParallaxCarousel()
                    .padding(15)
            }
            .navigationTitle("Puppers")
        }
    }
}

#Preview {
    ParallaxCarouselContentView()
}
