//
//  FlipTransitionView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 18.08.25.
//

import SwiftUI

struct FlipTransitionView: View {
    @State private var showView = false

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    if showView {
                        CardView(imageName: "berlinPupper")
                            .transition(.reverseFlip)
                    } else {
                        CardView(imageName: "readingPupper")
                            .transition(.flip)
                    }
                }
                .frame(width: 300)

                Button(showView ? "Hide" : "Show") {
                    withAnimation(.bouncy(duration: 2)) {
                        showView.toggle()
                    }
                }
                .padding()

                CardView(imageName: "berlinPupper")
                    .frame(width: 300)
                    // Positive degree rotation around y-axis for "into the screen" flip
                    .rotation3DEffect(.degrees(30), axis: (x: 0, y: 1, z: 0))
            }
            .navigationTitle("Custom Flip Transition")
        }
    }
}

private struct FlipTransition: ViewModifier, Animatable {
    var progress: CGFloat = 0

    // Without conforming to Animatable protocol, SwiftUI won't animate the transition
    // and will just jump to the end state.
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    // Positive degree rotation around y-axis for "into the screen" flip,
    // negative degree rotation around y-axis  for "out of the screen" flip.
    func body(content: Content) -> some View {
        content
            .opacity(progress < 0 ? (-progress < 0.5 ? 1 : 0) : (progress < 0.5 ? 1 : 0))
            .rotation3DEffect(.degrees(progress * 180), axis: (x: 0, y: 1, z: 0))
    }
}

private extension AnyTransition {
    static var flip: AnyTransition {
        .modifier(
            active: FlipTransition(progress: 1),
            identity: FlipTransition(progress: 0)
        )
    }

    static var reverseFlip: AnyTransition {
        .modifier(
            active: FlipTransition(progress: -1),
            identity: FlipTransition(progress: 0)
        )
    }
}

// MARK: - Preview

#Preview {
    FlipTransitionView()
}
