//
//  VerticalCircularCarousel.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 08.07.25.
//

import SwiftUI

struct VerticalCircularCarousel: View {
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(ItemModel.dogSamples) { item in
                        Image(item.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(radius: 15)
                            .visualEffect { content, proxy in
                                content
                                    .offset(x: -150)
                                    .rotationEffect(
                                        .degrees(rotationAngle(proxy)),
                                        anchor: .trailing
                                    )
                                    .offset(y: -proxy.frame(in: .scrollView(axis: .vertical)).minY)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .scrollTargetLayout()
            }
            .safeAreaPadding(.vertical, size.height * 0.5 - 75)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }

    private nonisolated func rotationAngle(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        let height = proxy.size.height
        let progress = minY / height

        let angle: CGFloat = -50.0

        let cappedProgress = progress < 0 ? min(max(progress, -3), 0) : max(min(progress, 3), 0)

        return cappedProgress * angle
    }
}

struct VerticalCircularCarouselContentView: View {
    var body: some View {
        NavigationStack {
            VerticalCircularCarousel()
                .background(.cyan.gradient)
        }
    }
}

#Preview {
    VerticalCircularCarouselContentView()
}
