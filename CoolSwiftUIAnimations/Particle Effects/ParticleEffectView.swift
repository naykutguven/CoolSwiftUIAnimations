//
//  ParticleEffectView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 13.07.25.
//

import SwiftUI

struct ParticleEffectView: View {
    @State private var isLiked: Bool = false
    @State private var isShared: Bool = false
    @State private var isStarred: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 20) {
                    customButton(
                        systemImage: "heart.fill",
                        status: isLiked,
                        activeTint: .pink,
                        inactiveTint: .gray
                    ) {
                        isLiked.toggle()
                    }

                    customButton(
                        systemImage: "star.fill",
                        status: isStarred,
                        activeTint: .yellow,
                        inactiveTint: .gray
                    ) {
                        isStarred.toggle()
                    }

                    customButton(
                        systemImage: "square.and.arrow.up.fill",
                        status: isShared,
                        activeTint: .blue,
                        inactiveTint: .gray
                    ) {
                        isShared.toggle()
                    }
                }
            }
            .navigationTitle("Particle Effect")
        }
        .colorScheme(.dark)
    }

    @ViewBuilder
    private func customButton(
        systemImage: String,
        status: Bool,
        activeTint: Color,
        inactiveTint: Color,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            Image(systemName: systemImage)
                .font(.title2)
                .particleEffect(
                    systemImage: systemImage,
                    status: status,
                    activeTint: activeTint,
                    inactiveTint: inactiveTint
                )
                .foregroundStyle(status ? activeTint : inactiveTint)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(status ? activeTint.opacity(0.25) : .gray.opacity(0.25))
                }
        }
    }
}

struct ParticleModel: Identifiable {
    let id = UUID()
    var randomX: CGFloat = 0
    var randomY: CGFloat = 0
    var scale: CGFloat = 1
    // Optional
    var opacity: CGFloat = 1

    mutating func reset() {
        randomX = 0
        randomY = 0
        scale = 1
        opacity = 1
    }
}

struct ParticleModifier: ViewModifier {
    var systemImage: String
    var status: Bool
    var activeTint: Color
    var inactiveTint: Color

    @State private var particles: [ParticleModel] = []

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack {
                    ForEach(particles) { particle in
                        Image(systemName: systemImage)
                            .foregroundStyle(status ? activeTint : inactiveTint)
                            .scaleEffect(particle.scale)
                            .offset(x: particle.randomX, y: particle.randomY)
                            .opacity(particle.opacity)
                            .opacity(status ? 1 : 0)
                            // Base visibility with no animation
                            .animation(nil, value: status)
                    }
                }
                .onAppear {
                    // Adding base particles
                    if particles.isEmpty {
                        for _ in 0..<15 {
                            particles.append(ParticleModel())
                        }
                    }
                }
                .onChange(of: status) { oldValue, newValue in
                    if !newValue {
                        // Reset particles when status changes to inactive
                        for index in particles.indices {
                            particles[index].reset()
                        }
                    } else {
                        for index in particles.indices {
                            let total = CGFloat(particles.count)
                            let progress = CGFloat(index) / total

                            let maxX: CGFloat = progress > 0.5 ? 100 : -100
                            let maxY: CGFloat = 60

                            let randomX = ((progress > 0.5) ? progress - 0.5 : progress) * maxX
                            let randomY = ((progress > 0.5) ? progress - 0.5 : progress) * maxY + 35

                            let randomScale = CGFloat.random(in: 0.35...1)

                            withAnimation(
                                .interactiveSpring(
                                    response: 0.6,
                                    dampingFraction: 0.7,
                                    blendDuration: 0.7
                                )
                            ) {
                                // Some extra randomness to spread particles
                                let extraRandomX: CGFloat = (progress < 0.5 ? .random(in: 0...10) : .random(in: -10...0))
                                let extraRandomY: CGFloat = .random(in: 0...30)

                                particles[index].randomX = randomX + extraRandomX
                                particles[index].randomY = -randomY - extraRandomY
                            }

                            withAnimation(.easeInOut(duration: 0.3)) {
                                particles[index].scale = randomScale
                            }

                            withAnimation(
                                .interactiveSpring(
                                    response: 0.6,
                                    dampingFraction: 0.7,
                                    blendDuration: 0.7
                                ).delay(0.25 + (Double(index) * 0.005))
                            ) {
                                particles[index].scale = 0.001
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    @ViewBuilder
    func particleEffect(
        systemImage: String,
        status: Bool,
        activeTint: Color,
        inactiveTint: Color
    ) -> some View {
        self
            .modifier(
                ParticleModifier(
                    systemImage: systemImage,
                    status: status,
                    activeTint: activeTint,
                    inactiveTint: inactiveTint
                )
            )
    }
}

#Preview {
    ParticleEffectView()
}
