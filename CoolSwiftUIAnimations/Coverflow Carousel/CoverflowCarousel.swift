//
//  CoverflowCarousel.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 08.07.25.
//

import SwiftUI

struct CoverflowCarousel<
    Content: View,
    Data: RandomAccessCollection
> : View where Data.Element: Identifiable {

    struct Config {
        var hasOpacity: Bool = true
        var opacityValue: Double = 0.5
        var hasScale: Bool = true
        var scaleValue: CGFloat = 0.2

        var cardWidth: CGFloat = 200
        var spacing: CGFloat = 10
        var cornerRadius: CGFloat = 15
        var minCardWidth: CGFloat = 40
    }

    @Binding var selection: Data.Element.ID?

    var config: Config = .init()
    var data: Data

    @ViewBuilder var content: (Data.Element) -> Content
    var body: some View {
        GeometryReader {
            let size = $0.size

            ScrollView(.horizontal) {
                HStack(spacing: config.spacing) {
                    ForEach(data) { item in
                        itemView(item)
                    }
                }
                .scrollTargetLayout()
            }
            // centering the scroll view content
            .safeAreaPadding(.horizontal, max(size.width - config.cardWidth, 0) / 2)
            .scrollPosition(id: $selection)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollIndicators(.hidden)
        }
    }

    @ViewBuilder
    func itemView(_ item: Data.Element) -> some View {
        GeometryReader { proxy in
            let size = proxy.size

            let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
            let progress = minX / (config.cardWidth + config.spacing)

            let widthDiff = config.cardWidth - config.minCardWidth
            let reduceWidth = progress * widthDiff

            let cappedDiff = min(abs(reduceWidth), widthDiff)

            let opacityValue = 1 - config.opacityValue * abs(progress)
            let scaleValue = 1 - config.scaleValue * abs(progress)

            content(item)
                .frame(width: size.width, height: size.height)
                .frame(width: size.width - cappedDiff)
                .clipShape(.rect(cornerRadius: config.cornerRadius))
                .opacity(config.hasOpacity ? opacityValue : 1)
                .scaleEffect(config.hasScale ? scaleValue : 1)
                // Moving items to the center as it scrolls left and shrinks.
                // reduceWidth is negative for items on the left side
                // -(progress * widthDiff)
                .offset(x: -reduceWidth)
                // But now the items on the right side are too close to the center
                // So we need to move them to the right by the reduced amount but capped.
                .offset(x: min(progress, 1) * widthDiff)
                // Doing the same for the left side.
                .offset(x: max(0, -progress) * widthDiff)
        }
        .frame(width: config.cardWidth)
    }
}



struct CoverflowCarouselContentView: View {
    @State private var activeID: ItemModel.ID?
    var body: some View {
        NavigationStack {
            VStack {
                CoverflowCarousel(
                    selection: $activeID,
                    data: ItemModel.dogSamples
                ) { item in
                    Image(item.imageName)
                        .resizable()
                        .scaledToFill()
                }
                .frame(height: 200)
            }
            .navigationTitle("Coverflow Carousel")
        }
    }
}

#Preview {
    CoverflowCarouselContentView()
}
