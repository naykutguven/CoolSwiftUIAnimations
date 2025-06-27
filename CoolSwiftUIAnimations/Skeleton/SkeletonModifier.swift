//
//  SkeletonModifier.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 27.06.25.
//

import SwiftUI

extension View {
    func skeleton(
        startAnimating: Bool = true,
        rotation: Double = 0.0,
        animation: Animation = .easeInOut(duration: 2.0).repeatForever(autoreverses: false)
    ) -> some View {
        modifier(
            SkeletonModifier(
                startAnimating: startAnimating,
                rotation: rotation,
                animation: animation
            )
        )
    }
}

struct SkeletonModifier: ViewModifier {
    var startAnimating = true
    var rotation: Double = 5.0
    var animation: Animation = .easeInOut(duration: 2.0).repeatForever(autoreverses: false)

    @State private var isAnimating = false
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .redacted(reason: startAnimating ? .placeholder : [])
            .overlay {
                if startAnimating {
                    GeometryReader { proxy in
                        // Calculating skeleton size
                        let size = proxy.size
                        let skeletonWidth = size.width / 3

                        // Blur effect for gradual movement
                        let blurRadius = max(skeletonWidth / 2, 30)
                        let blurDiameter = blurRadius * 2

                        // Movement offsets
                        let minX = -(skeletonWidth + blurDiameter)
                        let maxX = size.width + skeletonWidth + blurDiameter

                        Rectangle()
                            .fill(.white)
                            .frame(width: skeletonWidth, height: size.height * 2)
                            .frame(height: size.height)
                            .blur(radius: blurRadius)
                            .rotationEffect(.degrees(rotation))
                            .offset(x: isAnimating ? maxX : minX)
                    }
                    .mask {
                        content.redacted(reason: .placeholder)
                    }
                    .blendMode(.lighten)
                    .task {
                        guard !isAnimating else { return }
                        withAnimation(animation) {
                            isAnimating = true
                        }
                    }
                    .onDisappear {
                        isAnimating = false
                    }
                    .transaction {
                        if $0.animation != animation {
                            $0.animation = .none
                        }
                    }
                }
            }
    }
}

#Preview {
    @Previewable @State var isLoading = false
    let dog = ItemModel.dogSamples[0]

    VStack {
        CardView(imageName: dog.imageName)
        Text(dog.title)
            .font(.title)
        Text(dog.description)
            .font(.subheadline)
    }
    .skeleton(startAnimating: isLoading)
    .onTapGesture {
        isLoading.toggle()
    }
}
