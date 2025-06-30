//
//  StackedHorizontalScrollView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 27.06.25.
//

import SwiftUI

struct StackedHorizontalScrollView<
    Content: View,
    Data: RandomAccessCollection
>: View where Data.Element: Identifiable {
    var items: Data
    var stackedDisplayCount: Int = 3
    var spacing: CGFloat = 20
    let itemWidth: CGFloat

    let offsetForEachItem: CGFloat = 10.0
    let scaleForEachItem: CGFloat = 0.1

    @ViewBuilder var content: (Data.Element) -> Content

    @State private var safePadding: CGFloat = 0

    var body: some View {
        ZStack(alignment: .center) {
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                            .frame(width: itemWidth)
                            .visualEffect { content, proxy in
                                content
                                    .scaleEffect(scale(proxy), anchor: .trailing)
                                    .offset(x: offset(proxy))
                            }
                            .zIndex(zIndex(item))
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.never)
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.leading, safePadding)
        }
        // This is an iOS 18 alternative to the GeometryReader approach used in
        // StackedVerticalScrollView to calculate the safe area padding. It is called
        // only when the geometry of the ZStack changes.
        .onGeometryChange(for: CGFloat.self, of: { proxy in
            proxy.size.width
        }, action: { _, newValue in
            safePadding = newValue - itemWidth
        })
    }

    private func zIndex(_ item: Data.Element) -> Double {
        guard let index = items.firstIndex(where: { $0.id == item.id }) as? Int else {
            return 0
        }
        return Double(items.count - index)
    }

    private nonisolated func scale(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        let progress = minX / itemWidth
        let maxScale = CGFloat(stackedDisplayCount) * scaleForEachItem
        let scale = max(min(progress * scaleForEachItem, maxScale), 0)

        return 1 - scale
    }

    private nonisolated func offset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        let progress = minX / itemWidth
        let maxOffset = CGFloat(stackedDisplayCount) * offsetForEachItem
        let offset = max(min(progress * offsetForEachItem, maxOffset), 0)

        return minX < 0 ? 0 : -minX + offset
    }
}

#Preview {
    ZStack(alignment: .center) {
        Image(.ancientTree)
            .resizable()
            .ignoresSafeArea()
        StackedHorizontalScrollView(
            items: ItemModel.dogSamples,
            stackedDisplayCount: 2,
            itemWidth: 300
        ) { item in
            CardView(imageName: item.imageName)
                .frame(width: 300)
        }
        .safeAreaPadding(.trailing, 50)
        .frame(height: 320)
    }
}
