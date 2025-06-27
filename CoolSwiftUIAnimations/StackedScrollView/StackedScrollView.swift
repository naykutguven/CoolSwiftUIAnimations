//
//  StackedScrollView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 26.06.25.
//

import SwiftUI

struct StackedScrollView<
    Content: View,
    Data: RandomAccessCollection
>: View where Data.Element: Identifiable {
    var items: Data
    var stackedDisplayCount: Int = 3
    var spacing: CGFloat = 20
    let itemHeight: CGFloat

    let offsetForEachItem: CGFloat = 10.0
    let scaleForEachItem: CGFloat = 0.1

    @ViewBuilder var content: (Data.Element) -> Content

    var body: some View {
        GeometryReader { geometryProxy in
            let size = geometryProxy.size

            ScrollView(.vertical) {
                VStack(spacing: spacing) {
                    ForEach(items) { item in
                        content(item)
                            .frame(height: itemHeight)
                            .visualEffect { content, proxy in
                                content
                                    .scaleEffect(scale(proxy), anchor: .bottom)
                                    .offset(y: offset(proxy))
                            }
                            .zIndex(zIndex(item))
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .safeAreaPadding(.top, size.height - itemHeight)
        }
    }

    private func zIndex(_ item: Data.Element) -> Double {
        guard let index = items.firstIndex(where: { $0.id == item.id }) as? Int else {
            return 0
        }
        return Double(items.count - index)
    }

    private nonisolated func scale(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        let progress = minY / itemHeight
        let maxScale = CGFloat(stackedDisplayCount) * scaleForEachItem
        let scale = max(min(progress * scaleForEachItem, maxScale), 0)

        return 1 - scale
    }

    private nonisolated func offset(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        let progress = minY / itemHeight
        let maxOffset = CGFloat(stackedDisplayCount) * offsetForEachItem
        let offset = max(min(progress * offsetForEachItem, maxOffset), 0)

        return minY < 0 ? 0 : -minY + offset
    }
}

#Preview {
    ZStack {
        Image(.ancientTree)
            .resizable()
            .ignoresSafeArea()
        VStack {
            StackedScrollView(
                items: ItemModel.sceneSamples,
                stackedDisplayCount: 2,
                itemHeight: 50
            ) { item in
                NotificationView(
                    imageName: item.imageName,
                    title: item.title,
                    subtitle: item.description
                )
                .padding()
            }
            .safeAreaPadding(.bottom, 50)
        }
    }
}
