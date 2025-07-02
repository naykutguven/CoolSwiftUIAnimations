//
//  IntroPage.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 01.07.25.
//

import SwiftUI

struct IntroPage: View {
    private let items: [ItemModel] = ItemModel.dogSamples
    @State private var activeItem: ItemModel = ItemModel.dogSamples.first!

    // Auto scroll properties
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var currentScrollOffset: CGFloat = 0
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()

    // Nice text renderer animation for initial display
    @State private var initialAnimation = false
    @State private var titleProgress: CGFloat = 0

    @State private var scrollPhase: ScrollPhase = .idle

    var body: some View {
        ZStack {
            ambientBackground()
                .animation(.easeInOut(duration: 1.0), value: activeItem.id)

            VStack(spacing: 40) {
                // SwiftUI infinite scroll
                InfiniteScrollView {
                    ForEach(items) { item in
                        CardView(imageName: item.imageName)
                            .scrollTransition(
                                .interactive.threshold(.centered),
                                axis: .horizontal
                            ) { content, phase in
                                content
                                    .offset(y: phase.isIdentity ? -10 : 0)
                                    .rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
                            }
                    }
                }
                .containerRelativeFrame(.vertical) { length, _ in
                    length * 0.45
                }
                .scrollIndicators(.hidden)
                .scrollPosition($scrollPosition)
                .onScrollPhaseChange { oldPhase, newPhase in
                    scrollPhase = newPhase
                }
                .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
                    geometry.contentOffset.x + geometry.contentInsets.leading
                }, action: { oldValue, newValue in
                    // updating the current scroll offset after user drag so that
                    // auto scrolling can continue smoothly
                    currentScrollOffset = newValue

                    // only animates when the user is interacting or in auto-scroll
                    if scrollPhase != .decelerating || scrollPhase != .animating {
                        let index = Int((newValue / 220).rounded()) % items.count
                        activeItem = items[index]
                    }
                })
                .visualEffect { [initialAnimation] content, proxy in
                    content.offset(y: initialAnimation ? 0 : -(proxy.size.height + 200))
                }

                // Supplementary Apple Invites views
                VStack(spacing: 4) {
                    Text("Welcome to")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.secondary)
                        .blurOpacity(initialAnimation)

                    Text("Apple Invites")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .textRenderer(TitleTextRenderer(progress: titleProgress))
                        .padding(.bottom, 12)

                    Text("""
                         Create beautiful invitations for all your events.
                         Anyone can receive invitations. Sending included
                         with iCloud+.
                         """)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.secondary)
                    .blurOpacity(initialAnimation)
                }

                Button {
                    // Cancel the timer before navigating away
                    timer.upstream.connect().cancel()
                    // Navigate now.
                } label: {
                    Text("Create Event")
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                        .background(.white, in: .capsule)
                }
                .blurOpacity(initialAnimation)

                // MARK: - Without infite scroll
//                ScrollView(.horizontal) {
//                    HStack(spacing: 10) {
//                        ForEach(items) { item in
//                            CardView(imageName: item.imageName)
//                                .scrollTransition(
//                                    .interactive.threshold(.centered),
//                                    axis: .horizontal
//                                ) { content, phase in
//                                    content
//                                        .offset(y: phase.isIdentity ? -10 : 0)
//                                        .rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
//                                }
//                        }
//                    }
//                }
//                .onScrollGeometryChange(
//                    for: CGFloat.self,
//                    of: { geometry in
//                        geometry.contentInsets.leading + geometry.contentOffset.x
//                    },
//                    action: { oldValue, newValue in
//                        let index = Int((newValue / 220).rounded())
//                        activeItem = items[max(min(index, items.count - 1), 0)]
//                    }
//                )
            }
            .safeAreaPadding(15)
        }
        // Auto scroll
        .onReceive(timer) { _ in
            currentScrollOffset += 0.35
            scrollPosition.scrollTo(x: currentScrollOffset)
        }
        .task {
            withAnimation(.smooth(duration: 0.75).delay(0.35)) {
                initialAnimation = true
            }

            withAnimation(.smooth(duration: 2.5).delay(0.6)) {
                titleProgress = 1
            }
        }
    }

    @ViewBuilder
    private func ambientBackground() -> some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                ForEach(items) { item in
                    Image(item.imageName)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .frame(width: size.width, height: size.height)
                        .opacity(activeItem.id == item.id ? 1 : 0)
                }

                Rectangle()
                    .fill(.black.opacity(0.45))
                    .ignoresSafeArea()
            }
            .compositingGroup()
            .blur(radius: 90)
            .ignoresSafeArea()
        }
    }
}

// MARK: - SwiftUI Infinite Scroll - Not Continuous

// This version of infinite scroll in SwiftUI is claimed to be limited and not continuous.
// Better check the other version in "Auto Scrolling Infinite Carousel"
private struct InfiniteScrollView<Content: View>: View {
    var spacing: CGFloat = 10.0

    @ViewBuilder var content: Content

    // State properties
    @State private var contentSize: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    Group(subviews: content) { collection in
                        HStack(spacing: spacing) {
                            ForEach(collection) { view in
                                view
                            }
                        }
                        .onGeometryChange(for: CGSize.self) {
                            $0.size
                        } action: { newValue in
                            contentSize = .init(
                                width: newValue.width + spacing,
                                height: newValue.height
                            )
                        }

                        // Repeating content for infinite scroll
                        let averageWidth = contentSize.width / CGFloat(collection.count)
                        let repeatingCount = contentSize.width > 0 ? Int((size.width / averageWidth).rounded()) : 1

                        HStack(spacing: spacing) {
                            ForEach(0..<repeatingCount, id: \.self) { index in
                                let view = Array(collection)[index % collection.count]

                                view
                            }
                        }
                    }
                }
                // MARK: - Adding the UIKit helper here to make it truly infinite
                .background(
                    InfiniteScrollHelper(
                        contentSize: $contentSize,
                        decelerationRate: .constant(.fast)
                    )
                )
            }
        }
    }
}

// MARK: - UIKit Wrapper Infinite Scroll


private struct InfiniteScrollHelper: UIViewRepresentable {
    @Binding var contentSize: CGSize
    @Binding var decelerationRate: UIScrollView.DecelerationRate


    func makeCoordinator() -> Coordinator {
        Coordinator(decelerationRate: decelerationRate, contentSize: contentSize)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            if let scrollView = view.scrollView {
                context.coordinator.defaultDelegate = scrollView.delegate
                scrollView.decelerationRate = decelerationRate
                scrollView.delegate = context.coordinator
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.decelerationRate = decelerationRate
        context.coordinator.contentSize = contentSize
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var decelerationRate: UIScrollView.DecelerationRate
        var contentSize: CGSize

        // Default SwiftUI Delegate
        weak var defaultDelegate: UIScrollViewDelegate?

        init(decelerationRate: UIScrollView.DecelerationRate, contentSize: CGSize) {
            self.decelerationRate = decelerationRate
            self.contentSize = contentSize
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollView.decelerationRate = decelerationRate

            let minX = scrollView.contentOffset.x

            // End of the scrollable content
            if minX > contentSize.width {
                scrollView.contentOffset.x -= contentSize.width
            }

            // Beginning of the scrollable content
            if minX < 0 {
                scrollView.contentOffset.x += contentSize.width
            }

            defaultDelegate?.scrollViewDidScroll?(scrollView)
        }

        // Calling some default callbacks to make it work with SwiftUI
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            defaultDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            defaultDelegate?.scrollViewDidEndDecelerating?(scrollView)
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            defaultDelegate?.scrollViewWillBeginDragging?(scrollView)
        }

        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            defaultDelegate?.scrollViewWillEndDragging?(
                scrollView,
                withVelocity: velocity,
                targetContentOffset: targetContentOffset
            )
        }
    }
}

private extension UIView {
    var scrollView: UIScrollView? {
        if let superview = superview as? UIScrollView {
            return superview
        }
        return superview?.scrollView
    }
}

private extension View {
    func blurOpacity(_ show: Bool) -> some View {
        self
            .blur(radius: show ? 0 : 2)
            .opacity(show ? 1 : 0)
            .scaleEffect(show ? 1 : 0.9)
    }
}

// MARK: - Text Renderer

private struct TitleTextRenderer: TextRenderer, Animatable {
    var progress: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        let runs = layout.flatMap { $0 }.flatMap { $0 } // layout -> line -> run

        for (index, run) in runs.enumerated() {
            let runProgressIndex = CGFloat(runs.count) * progress
            let runProgress = max(min(runProgressIndex / CGFloat(index + 1), 1), 0)

            ctx.addFilter(.blur(radius: 5 - 5 * runProgress))
            ctx.opacity = runProgress
            ctx.translateBy(x: 0, y: 5 - 5 * runProgress)
            ctx.draw(run, options: .disablesSubpixelQuantization) // this option is for preventing jittering in animated text
        }
    }
}

// MARK: - Preview

#Preview {
    IntroPage()
}
