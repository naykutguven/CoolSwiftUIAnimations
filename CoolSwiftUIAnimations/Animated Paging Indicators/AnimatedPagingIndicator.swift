//
//  AnimatedPagingIndicator.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 09.07.25.
//

import SwiftUI

struct AnimatedPagingIndicator: View {
    var activeTint: Color = .white
    var inActiveTint: Color = .gray
    var opacityEffect: Bool = false
    var clipEdges: Bool = true

    private let spacing: CGFloat = 10
    private let indicatorWidth: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            if let scrollViewWidth = geometry.bounds(of: .scrollView(axis: .horizontal))?.width,
               scrollViewWidth > 0 {
                // Calculating the number of pages based on the scroll view width.
                // We can do this without knowing the item width because each item is full width.
                let pageCount = Int(width / scrollViewWidth)

                let minX = geometry.frame(in: .scrollView(axis: .horizontal)).minX
                // Progress
                let freeProgress = -minX / scrollViewWidth
                let clippedProgress = min(max(freeProgress, 0), CGFloat(pageCount - 1))
                let progress = clipEdges ? clippedProgress : freeProgress

                // Index calculation
                let activeIndex = Int(progress)
                let nextIndex = Int(progress.rounded(.awayFromZero))

                let indicatorProgress = progress - CGFloat(activeIndex)
                let maxIndicatorWidth = indicatorWidth + spacing
                let currentPageIndicatorWidth = maxIndicatorWidth - (indicatorProgress * spacing)
                let nextPageIndicatorWidth = spacing * indicatorProgress + indicatorWidth

                HStack(spacing: spacing) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        Capsule()
                            .fill(.clear)
                            .frame(
                                width: index == activeIndex ? currentPageIndicatorWidth :
                                    nextIndex == index ? nextPageIndicatorWidth : indicatorWidth,
                                height: indicatorWidth
                            )
                            .overlay {
                                ZStack {
                                    Capsule().fill(inActiveTint)
                                    Capsule()
                                        .fill(activeTint)
                                        .opacity(opacityEffect ?
                                                 activeIndex == index ? 1 - indicatorProgress :
                                                    nextIndex == index ? indicatorProgress : 0 :
                                                    1
                                        )
                                }
                            }
                    }
                }
                .frame(width: scrollViewWidth)
//                .overlay {
//                    VStack {
//                        Text("\(activeIndex) \(nextIndex)")
//                    }
//                    .bold()
//                    .foregroundStyle(.red)
//                    .offset(y: -100)
//                }
                .offset(x: -minX)

            }
        }
        .frame(height: 30)
    }
}

private struct AnimatedPagingIndicatorContentView: View {
    @State private var opacityEffect = false
    @State private var clipEdges = false

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(ItemModel.dogSamples) { item in
                            CardView(imageName: item.imageName, orientation: .horizontal)
                                .padding(.horizontal, 5)
                                .containerRelativeFrame(.horizontal)
                                .border(.green)
                        }
                    }
                    .scrollTargetLayout()
                    .overlay(alignment: .bottom) {
                        AnimatedPagingIndicator(opacityEffect: opacityEffect, clipEdges: clipEdges)
                    }
                }
                // we can use paging, too.
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
                .border(.red)
                .frame(height: 300)
                .border(.blue)
                .safeAreaPadding(.horizontal, 25)
                .border(.black)

                List {
                    Section("Options") {
                        Toggle("Show Opacity", isOn: $opacityEffect)
                        Toggle("Clip edges", isOn: $clipEdges)
                    }
                }
                .clipShape(.rect(cornerRadius: 32))
                .padding()
            }
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle("Animated Paging Indicator")
        }
    }
}

#Preview {
    AnimatedPagingIndicatorContentView()
}
