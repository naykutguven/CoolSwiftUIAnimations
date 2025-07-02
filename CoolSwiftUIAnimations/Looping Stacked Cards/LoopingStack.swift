//
//  LoopingStack.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 02.07.25.
//

import SwiftUI

struct LoopingStack<Content: View>: View {
    var visibleCardsCount: Int = 2
    @ViewBuilder var content: Content

    @State private var rotation: Int = 0

    var body: some View {
        Group(subviews: content) { collection in
            let collection = collection.rotateFromLeft(by: rotation)
            let count = collection.count

            ZStack {
                ForEach(collection) { view in
                    let index = collection.index(view)

                    LoopingStackCardView(
                        index: index,
                        count: count,
                        visibleCardsCount: visibleCardsCount,
                        rotation: $rotation
                    ) {
                        view
                    }

                    .zIndex(Double(count - index))
                }
            }
        }
    }
}

// Container view for cards so we can store offset individually
private struct LoopingStackCardView<Content: View>: View {
    var index: Int
    var count: Int
    var visibleCardsCount: Int

    @Binding var rotation: Int

    // Interaction properties
    @State private var offset: CGFloat = 0

    @State private var viewSize: CGSize = .zero

    @ViewBuilder var content: Content

    var body: some View {
        content
            .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { newValue in
                viewSize = newValue
            })
            .offset(x: offset(at: index))
            .scaleEffect(scale(at: index), anchor: .trailing)
        // Adding animation so that the card below is palced with animation
            .animation(.smooth(duration: 0.25), value: index)
            .offset(x: index == 0 ? offset : 0)
            .rotation3DEffect(rotationAngle(), axis: (x: 0, y: 1, z: 0), anchor: .center, perspective: 0.5)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow dragging to left
                        let xOffset = -max(-value.translation.width, 0)
                        offset = xOffset
                    }
                    .onEnded { value in
                        let xVelocity = max(-value.velocity.width / 5, 0)

                        // Threshold for pushing the card to the back of the deck
                        if (-offset + xVelocity) > (viewSize.width * 0.65) {
                            pushToNextCard()
                        } else {
                            withAnimation(.smooth(duration: 0.3)) {
                                offset = .zero
                            }
                        }
                    }
                , isEnabled: index == 0 && count > 1
            )
    }

    private func pushToNextCard() {
        // First moving the card so the z-index effect won't be visible and it will appear
        // as if it is receding behind
        withAnimation(
            .smooth(duration: 0.25)
            .logicallyComplete(after: 0.15),
            {
                offset = -viewSize.width
            }, completion: {
                rotation += 1
                withAnimation(.smooth(duration: 0.25)) {
                    offset = .zero
                }
            }
        )
    }

    private func offset(at index: Int) -> CGFloat {
        let offsetForEachItem: CGFloat = 20
        let maxOffset = CGFloat(visibleCardsCount) * offsetForEachItem
        let extraOffset = min(CGFloat(index) * offsetForEachItem, maxOffset)
        return extraOffset
    }

    private func scale(at index: Int) -> CGFloat {
        let scaleDownForEachItem: CGFloat = 0.07
        let maxScaleDown = CGFloat(visibleCardsCount) * scaleDownForEachItem
        let scale = 1 - min(CGFloat(index) * scaleDownForEachItem, maxScaleDown)
        return scale
    }

    private func rotationAngle() -> Angle {
        let maxRotation: CGFloat = -30
        let rotation = max(min(-offset / viewSize.width, 1), 0) * maxRotation
        return .degrees(rotation)
    }
}

// MARK: - Helper extensions

private extension SubviewsCollection {
    func rotateFromLeft(by amount: Int) -> [SubviewsCollection.Element] {
        guard !isEmpty else { return [] }
        let move = amount % count
        let rotated = Array(self[move...]) + Array(self[..<move])
        return rotated
    }
}

private extension  [SubviewsCollection.Element] {
    func index(_ subview: SubviewsCollection.Element) -> Int {
        firstIndex { $0.id == subview.id } ?? 0
    }
}

// MARK: - Usage Sample

private struct LoopingStackHomePage: View {
    private let items = ItemModel.dogSamples

    var body: some View {
        NavigationStack {
            VStack {
                LoopingStack {
                    ForEach(items) { item in
                        CardView(imageName: item.imageName)
                            .frame(width: 200)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.gray.opacity(0.2))
            .navigationTitle("Looping Stack")
        }
    }
}

#Preview {
    LoopingStackHomePage()
}
