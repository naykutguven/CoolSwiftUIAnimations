//
//  ResizableHeaderScrollView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 26.08.25.
//

import SwiftUI

struct ResizableHeaderScrollView<
    Header: View,
    StickyHeader: View,
    Background: View,
    Content: View
>: View {
    var spacing: CGFloat = 10
    @ViewBuilder var header: Header
    @ViewBuilder var stickyHeader: StickyHeader
    // only for header background
    @ViewBuilder var background: Background

    @ViewBuilder var content: Content

    // View properties
    @State private var currentDragOffset: CGFloat = 0
    @State private var previousDragOffset: CGFloat = 0
    @State private var headerOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 0

    @State private var scrollOffsetY: CGFloat = 0

    var body: some View {
        ScrollView {
            content
        }
        .onScrollGeometryChange(for: CGFloat.self, of: { geo in
            geo.contentOffset.y + geo.contentInsets.top
        }, action: { oldValue, newValue in
            scrollOffsetY = newValue
        })
        .frame(maxWidth: .infinity)
        // This is the key part of the implementation
        .simultaneousGesture(
            DragGesture(minimumDistance: 10)
                .onChanged({ value in
                    // This way (by setting it 50), we give the user a little bit of space to
                    // start the drag gesture without immediately affecting
                    // the header size.
                    // Negative because dragging down should increase the header size
                    let dragOffset = -max(0, abs(value.translation.height) - 50) *
                    (value.translation.height < 0 ? -1 : 1)

                    // back to back state updates? hmm
                    previousDragOffset = currentDragOffset
                    currentDragOffset = dragOffset

                    let deltaOffset = (currentDragOffset - previousDragOffset).rounded()

                    headerOffset = max(min(headerOffset + deltaOffset, headerHeight), 0)
                })
                .onEnded({ _ in
                    withAnimation(.easeOut(duration: 0.25)) {
                        if headerOffset > (headerHeight * 0.5) && scrollOffsetY > headerHeight {
                            headerOffset = headerHeight
                        } else {
                            headerOffset = 0
                        }
                    }
                    // Resetting offset data
                    currentDragOffset = 0
                    previousDragOffset = 0
                })
        )
        .safeAreaInset(edge: .top, spacing: spacing) {
            combinedHeaderView()
        }
    }

    @ViewBuilder
    private func combinedHeaderView() -> some View {
        VStack(spacing: spacing) {
            header
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { newValue in
                    headerHeight = newValue + spacing
                }

            stickyHeader
        }
        .offset(y: -headerOffset)
        .clipped()
        .background {
            background
                .ignoresSafeArea()
                .offset(y: -headerOffset)
        }
    }
}

private struct ResizableHeaderScrollContentView: View {
    var body: some View {
        ResizableHeaderScrollView {
            HStack(spacing: 12) {
                Button {

                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }

                Spacer(minLength: 0)

                Button {

                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                }

                Button {

                } label: {
                    Image(systemName: "bubble")
                        .font(.title3)
                }
            }
            .overlay {
                Text("Apple Store")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 15)
            .padding(.top, 15)
        } stickyHeader: {
            HStack {
                Text("Total \(25)")
                    .fontWeight(.semibold)

                Spacer(minLength: 0)

                Button {

                } label: {
                    Image(systemName: "slider.vertical.3")
                        .font(.title3)
                }
            }
            .foregroundStyle(Color.primary)
            .padding(15)
            .padding(.vertical, 10)
        } background: {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .bottom) {
                    Divider()
                }
        } content: {
            VStack(spacing: 15) {
                ForEach(1...100, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.gray.opacity(0.35))
                        .frame(height: 50)
                }
            }
            .padding(15)
        }
    }
}

#Preview {
    ResizableHeaderScrollContentView()
}
