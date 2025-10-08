//
//  SlideToConfirmButton.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 08.10.25.
//

import SwiftUI

struct SlideToConfirmButton: View {
    struct Config {
        var idleText: String
        var onSwipeText: String
        var confirmationText: String
        var tint: Color
        var foreground: Color
        var height: CGFloat = 70
    }

    var config: Config
    var onSwiped: () -> Void

    @State private var animateText = false
    @State private var offsetX: CGFloat = 0
    @State private var isCompleted = false

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let knobSize = size.height
            let maxLimit = size.width - knobSize

            let progress: CGFloat = isCompleted ? 1 : (offsetX / maxLimit)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(
                        .gray.opacity(0.25)
                        .shadow(.inner(color: .black.opacity(0.2), radius: 10))
                    )

                // Tint Capsule
                Capsule()
                    .fill(config.tint.gradient)
                    .frame(width: knobSize + progress * maxLimit, height: knobSize)

                confirmationTextView(size, progress: progress)

                HStack(spacing: 0) {
                    knobView(size, progress: progress, maxLimit: maxLimit)
                        .zIndex(1)

                    shimmerTextView(size, progress: progress)
                }
            }
        }
        .frame(height: isCompleted ? 50 : config.height)
        .containerRelativeFrame(.horizontal) { value, _ in
            let ratio = isCompleted ? 0.5 : 0.8
            return ratio * value
        }
        .frame(maxWidth: 300)
        .allowsHitTesting(!isCompleted)
    }

    private func knobView(_ size: CGSize, progress: CGFloat, maxLimit: CGFloat) -> some View {
        Circle()
            .fill(.background)
            .padding(6)
            .frame(width: size.height, height: size.height)
            .overlay {
                ZStack {
                    Image(systemName: "chevron.right")
                        .opacity(1 - progress)
                        .blur(radius: progress * 10)

                    Image(systemName: "checkmark")
                        .opacity(progress)
                        .blur(radius: (1 - progress) * 10)
                }
                .font(.title3.bold())
            }
            .contentShape(.circle)
            .scaleEffect(isCompleted ? 0.6 : 1)
            .offset(x: isCompleted ? maxLimit : offsetX)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        offsetX = min(max(value.translation.width, 0), maxLimit)
//                        print("OffsetX: \(offsetX)")
                    })
                    .onEnded({ value in
                        if offsetX == maxLimit {
                            // Confirmed
                            onSwiped()
                            animateText = false

                            withAnimation(.smooth) {
                                isCompleted = true
                            }
                        } else {
                            // Not confirmed, reset
                            withAnimation(.smooth) {
                                offsetX = 0
                            }
                        }
                    })
            )
    }

    private func shimmerTextView(_ size: CGSize, progress: CGFloat) -> some View {
        Text(isCompleted ? config.confirmationText : config.idleText)
            .foregroundStyle(.gray.opacity(0.6))
            .overlay {
                // Shimmer effect
                Rectangle()
                    .frame(height: 15)
                    .rotationEffect(.degrees(90))
                    .visualEffect { [animateText] content, proxy in
                        content
                            .offset(x: -proxy.size.width / 1.8)
                            .offset(x: animateText ? proxy.size.width * 1.2 : 0)
                    }
                    .mask(alignment: .leading) {
                        Text(config.idleText)
                    }
                    .blendMode(.softLight)
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
        // To make it center aligned
            .padding(.trailing, size.height / 2)
        // Masks the text when sliding
            .mask({
                Rectangle()
                    .scale(x: 1 - progress, anchor: .trailing)
            })
//            .border(.red)

            .frame(height: size.height)
            .task {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    animateText = true
                }
            }
    }

    private func confirmationTextView(_ size: CGSize, progress: CGFloat) -> some View {
        ZStack {
            Text(config.onSwipeText)
                .opacity(isCompleted ? 0 : 1)
                .blur(radius: isCompleted ? 10 : 0)


            Text(config.confirmationText)
                .opacity(isCompleted ? 1 : 0)
                .blur(radius: isCompleted ? 0 : 10)
        }
        .fontWeight(.semibold)
        .foregroundStyle(config.foreground)
        .frame(maxWidth: .infinity)
        // To make it center aligned
        // Scaling is needed here because we scale down the knob on completion
        .padding(.trailing, (size.height * (isCompleted ? 0.6 : 1)) / 2)
        // Masks the text when sliding
        .mask({
            Rectangle()
                .scale(x: progress, anchor: .leading)
        })
        //            .border(.red)
        .frame(height: size.height)

    }
}

private struct SlideToConfirmContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                let config = SlideToConfirmButton.Config(
                    idleText: "Swipe to Pay",
                    onSwipeText: "Keep Sliding...",
                    confirmationText: "Confirmed!",
                    tint: .green,
                    foreground: .white
                )

                SlideToConfirmButton(config: config) {
                    print("Confirmed!")
                }
            }
            .padding()
            .navigationTitle("Slide to Confirm")
        }
    }
}

// MARK: - Preview

#Preview {
    SlideToConfirmContentView()
}
