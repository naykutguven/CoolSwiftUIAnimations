//
//  HeartParticle.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 10.07.25.
//

import SwiftUI

struct HeartParticle: Identifiable {
    var id: UUID = UUID()
}

struct HeartParticleView: View {
    @State private var beatAnimation: Bool = false
    @State private var showPulses: Bool = false
    @State private var pulsedHearts: [HeartParticle] = []

    var body: some View {
        VStack {
            ZStack {
                if showPulses {
                    TimelineView(.animation(minimumInterval: 0.7, paused: false)) { timeline in
                        // With ZStack
                        ZStack {
                            ForEach(pulsedHearts) { _ in
                                PulseHeartView()
                            }
                        }
                        .onChange(of: timeline.date) { oldValue, newValue in
                            if beatAnimation {
                                addPulsedHeart()
                            }
                        }

                        // With Canvas
//                        Canvas { context, size in
//                            for heart in pulsedHearts {
//                                if let resolvedView = context.resolveSymbol(id: heart.id) {
//                                    let centerX = size.width / 2
//                                    let centerY = size.height / 2
//
//                                    context.draw(resolvedView, at: CGPoint(x: centerX, y: centerY))
//                                }
//                            }
//                        } symbols: {
//                            ForEach(pulsedHearts) { heart in
//                                PulseHeartView()
//                                    .id(heart.id)
//                            }
//                        }
//                        .onChange(of: timeline.date) { oldValue, newValue in
//                            if beatAnimation {
//                                addPulsedHeart()
//                            }
//                        }
                    }
                }
                Image(systemName: "heart.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.pink.gradient)
                    .symbolEffect(
                        .bounce,
                        options: .repeat(.periodic).speed(1),
                        value: beatAnimation
                    )
            }
            .frame(maxWidth: 350, maxHeight: 350)
            .background(.bar, in: .rect(cornerRadius: 20))

            Toggle("Beat Animation", isOn: $beatAnimation)
                .padding()
                .frame(maxWidth: 350)
                .background(.bar, in: .rect(cornerRadius: 20))
                .padding(.top, 20)
                .onChange(of: beatAnimation) { oldValue, newValue in
                    if pulsedHearts.isEmpty {
                        showPulses = true
                    }

                    if newValue, pulsedHearts.isEmpty {
                        // The first pulse isn't added immediately, so we add it here.
                        addPulsedHeart()
                    }
                }
                .disabled(!beatAnimation && !pulsedHearts.isEmpty)
        }
    }

    private func addPulsedHeart() {
        let pulsedHeart = HeartParticle()
        pulsedHearts.append(pulsedHeart)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            pulsedHearts.removeAll { $0.id == pulsedHeart.id }

            if pulsedHearts.isEmpty {
                showPulses = false
            }
        }
    }
}

private struct PulseHeartView: View {
    @State private var startAnimation: Bool = false

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 100))
            .foregroundStyle(.pink.gradient)
            // Some extra styling
            .background {
                Image(systemName: "heart.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.black)
                    .blur(radius: 15)
                    .scaleEffect(startAnimation ? 1.1 : 0.0)
                    .animation(.linear(duration: 1.5), value: startAnimation)
            }
            // Animations
            .scaleEffect(startAnimation ? 4.0 : 1.0)
            .opacity(startAnimation ? 0.0 : 0.7)
            .onAppear {
                withAnimation(.linear(duration: 3.0)) {
                    startAnimation = true
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HeartParticleView()
            .colorScheme(.dark)
    }
}
