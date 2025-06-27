//
//  StaggeredView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 27.06.25.
//

import SwiftUI


struct StaggeredConfiguration {
    var delay: Double = 0.05
    var maxDelay: Double = 0.8
    var blurRadius: CGFloat = 8
    var offset: CGSize = .init(width: 420, height: 0)
    var scale: CGFloat = 0.95
    var scaleAnchor: UnitPoint = .center
    var animation: Animation = .smooth(duration: 0.3, extraBounce: 0)
    var disappearInSameDirection: Bool = false
    var noDisappearAnimation: Bool = false
}

struct StaggeredView<Content: View>: View {
    var configuration = StaggeredConfiguration()
    @ViewBuilder var content: Content

    var body: some View {
        Group(subviews: content) { collection in
            ForEach(collection.indices, id: \.self) { index in
                collection[index]
                    .transition(StaggeredTransition(index: index, configuration: configuration))
            }
        }
    }
}

// This seems very computationally expensive, wonder if it is because of the ultraThinMaterial
// in NotificationView
struct StaggeredTransition: Transition {
    var index: Int
    var configuration: StaggeredConfiguration

    func body(content: Content, phase: TransitionPhase) -> some View {
        let delay = min(Double(index) * configuration.delay, configuration.maxDelay)

        let isIdentity = phase == .identity
        let didDisappear = phase == .didDisappear
        let x = configuration.offset.width
        let y = configuration.offset.height

        let reverseX = configuration.disappearInSameDirection ? x : -x
        let disableX = configuration.noDisappearAnimation ? 0 : reverseX

        let reverseY = configuration.disappearInSameDirection ? y : -y
        let disableY = configuration.noDisappearAnimation ? 0 : reverseY

        let offsetX = isIdentity ? 0 : (didDisappear ? disableX : x)
        let offsetY = isIdentity ? 0 : (didDisappear ? disableY : y)

        content
            .opacity(isIdentity ? 1 : 0)
            .blur(radius: isIdentity ? 0 : configuration.blurRadius)
            .compositingGroup()
            .scaleEffect(isIdentity ? 1 : configuration.scale, anchor: configuration.scaleAnchor)
            .offset(x: offsetX, y: offsetY)
            .animation(
                configuration.animation.delay(delay),
                value: phase
            )
    }
}

#Preview {
    StaggeredViewContainer()
}
