//
//  ScrollableTabView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 18.08.25.
//

import SwiftUI

struct ScrollableTabView: View {
    var body: some View {
        HeaderPageScrollView(displaysSymbols: true) {
            RoundedRectangle(cornerRadius: 30)
                .fill(.blue.gradient)
                .frame(height: 350)
                .padding(15)
        } labels: {
            PageLabel(title: "Posts", symbolImage: "square.grid.3x3.fill")
            PageLabel(title: "Reels", symbolImage: "photo.stack.fill")
            PageLabel(title: "Tagged", symbolImage: "person.crop.rectangle")
        } pages: {
            dummyList(color: .red)

            dummyList(color: .orange)

            dummyList(color: .yellow)
        }

    }

    @ViewBuilder
    private func dummyList(color: Color) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(0..<20) { index in
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.gradient)
                    .frame(height: 100)
            }
        }
        .padding()
    }
}

private struct PageLabel {
    var title: String
    var symbolImage: String
}

@resultBuilder
private struct PageLabelBuilder {
    static func buildBlock(_ components: PageLabel...) -> [PageLabel] {
        components.compactMap { $0 }
    }
}

private struct HeaderPageScrollView<Header: View, Pages: View>: View {
    var displaysSymbols: Bool = false

    // Header view
    var header: Header
    // Tab Label (title or image)
    var labels: [PageLabel]
    // Tab views
    var pages: Pages

    // View properties
    @State private var activeTab: String?
    @State private var headerHeight: CGFloat = 0

    // Properties to manage scroll positions
    @State private var scrollGeometries: [ScrollGeometry]
    @State private var scrollPositions: [ScrollPosition]

    init(
        displaysSymbols: Bool,
        @ViewBuilder header: @escaping () -> Header,
        @PageLabelBuilder labels:  @escaping () -> [PageLabel],
        @ViewBuilder pages: @escaping () -> Pages
    ) {
        self.displaysSymbols = displaysSymbols
        self.header = header()
        self.labels = labels()
        self.pages = pages()

        let count = self.labels.count
        self._scrollGeometries = State(initialValue: Array(repeating: ScrollGeometry(), count: count))
        self._scrollPositions = State(initialValue: Array(repeating: ScrollPosition(), count: count))
    }

    var body: some View {
        GeometryReader {
            let size = $0.size

            ScrollView(.horizontal) {
                // Using HStack allows us to maintain references to other scrollviews
                // enabling us to update them when necessary.
                HStack(spacing: 0) {
                    Group(subviews: pages) { collection in
                        if collection.count != labels.count {
                            Text("Labels count and pages count must match.")
                        } else {
                            ForEach(labels, id: \.title) { label in
                                pageScrollView(
                                    label: label,
                                    size: size,
                                    collection: collection
                                )
                            }
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $activeTab)
            .scrollIndicators(.hidden)
            .mask {
                Rectangle()
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .onAppear {
                guard activeTab == nil, let firstLabel = labels.first else { return }
                activeTab = firstLabel.title
            }
        }
    }

    @ViewBuilder
    func pageScrollView(
        label: PageLabel,
        size: CGSize,
        collection: SubviewsCollection
    ) -> some View {
        let index = labels.firstIndex(where: { $0.title == label.title }) ?? 0

        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ZStack {
                    if activeTab == label.title {
                        header
                            .visualEffect { content, proxy in
                                content
                                    .offset(x: -proxy.frame(in: .scrollView(axis: .horizontal)).minX)
                            }
                            .onGeometryChange(for: CGFloat.self) { proxy in
                                proxy.size.height
                            } action: { newValue in
                                headerHeight = newValue
                            }
                        // Adding transition here and below doesn't seem necessary :/
                            .transition(.identity)
                    } else {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: headerHeight)
                            .transition(.identity)
                    }
                }

                Section {
                    collection[index]
                    // Let's make it scrollable to the top even if the view doesn't have enough content.
                        .frame(minHeight: size.height - 40, alignment: .top)
                } header: {
                    ZStack {
                        if activeTab == label.title {
                            customTabBar()
                                .visualEffect { content, proxy in
                                    content
                                        .offset(x: -proxy.frame(in: .scrollView(axis: .horizontal)).minX)
                                }
                                .transition(.identity)
                        } else {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .frame(height: 40)
                                .transition(.identity)
                        }
                    }
                }

            }
        }
        .onScrollGeometryChange(for: ScrollGeometry.self, of: {
            $0
        }, action: { oldValue, newValue in
            scrollGeometries[index] = newValue

            if newValue.offsetX < 0 {
                resetScrollViews(label)
            }
        })
        .scrollPosition($scrollPositions[index])
        .onScrollPhaseChange({ oldPhase, newPhase in
            let geometry = scrollGeometries[index]
            let maxOffset = min(geometry.offsetY, headerHeight)

            if newPhase == .idle && maxOffset <= headerHeight {
                updateOtherScrollViews(label, to: maxOffset)
            }
        })
        .frame(width: size.width)
        .scrollClipDisabled()
        .zIndex(activeTab == label.title ? 1000 : 0)
    }

    @ViewBuilder
    func customTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(labels, id: \.title) { label in
                Group {
                    if displaysSymbols {
                        Image(systemName: label.symbolImage)
                    } else {
                        Text(label.title)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(activeTab == label.title ? Color.primary : .gray)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        activeTab = label.title
                    }
                }
            }
        }
        .frame(height: 40)
        .background(.background)
    }

    func resetScrollViews(_ from: PageLabel) {
        for index in labels.indices {
            let label = labels[index]
            if label.title != from.title {
                scrollPositions[index].scrollTo(y: .zero)
            }
        }
    }

    func updateOtherScrollViews(_ from: PageLabel, to: CGFloat) {
        for index in labels.indices {
            let label = labels[index]
            let offset = scrollGeometries[index].offsetY

            let shouldUpdate = offset < headerHeight || headerHeight > to

            if label.title != from.title && shouldUpdate {
                scrollPositions[index].scrollTo(y: to)
            }

        }
    }
}

// MARK: - Extensions

private extension ScrollGeometry {
    init() {
        self.init(
            contentOffset: .zero,
            contentSize: .zero,
            contentInsets: .init(.zero),
            containerSize: .zero
        )
    }

    // Already implemented somewhere else in the project
//    var offsetY: CGFloat {
//        contentOffset.y + contentInsets.top
//    }

    var offsetX: CGFloat {
        contentOffset.x + contentInsets.leading
    }
}

// MARK: - Previews

#Preview {
    ScrollableTabView()
}
