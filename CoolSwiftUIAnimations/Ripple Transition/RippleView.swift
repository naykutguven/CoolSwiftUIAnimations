//
//  RippleView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 30.06.25.
//

import SwiftUI

struct RippleView: View {
    @State private var flag = false
    @State private var rippleLocation: CGPoint = .zero

    @State private var showOverlay = false
    @State private var overlayRippleLocation: CGPoint = .zero

    var body: some View {
        NavigationStack {
            VStack {
                if flag {
                    CardView(imageName: ItemModel.dogSamples[0].imageName)
                        .transition(.ripple(location: rippleLocation))
                } else {
                    CardView(imageName: ItemModel.dogSamples[1].imageName)
                        .transition(.ripple(location: rippleLocation))
                }
            }
            .padding()
            .coordinateSpace(.named("ripple"))
            .onTapGesture(count: 1, coordinateSpace: .named("ripple")) { loc in
                rippleLocation = loc
                withAnimation(.linear(duration: 0.6)) {
                    flag.toggle()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottomTrailing) {
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .global)

                    Button {
                        overlayRippleLocation = CGPoint(x: frame.midX, y: frame.midY)
                        withAnimation(.linear(duration: 0.5)) {
                            showOverlay = true
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(.indigo.gradient, in: .circle)
                            .contentShape(.rect)
                    }
                }
                .frame(width: 50, height: 50)
                .padding(15)
            }
            .navigationTitle("Ripple Transition")
        }
        .overlay {
            if showOverlay {
                ZStack {
                    Rectangle()
                        .fill(.indigo.gradient)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.linear(duration: 0.5)) {
                                showOverlay = false
                            }
                        }
                    Text("Tap to dismiss")
                        .font(.title)
                        .foregroundStyle(.white)
                }
                .transition(.reverseRipple(location: overlayRippleLocation))
            }
        }
    }
}

extension AnyTransition {
    static func ripple(location: CGPoint) -> AnyTransition {
        // We can easily observe that the insertion and removal transitions occur simultaneously
        // when we comment out the last three circles. To mitigate this and show the ripple effect
        // only for the insertion, we can use a separate simple transition for the identity state.
        //
        // We are doing this because the ripple transition is applied to two different views inside
        // an if-else statement.
        .asymmetric(
            insertion: .modifier(
                active: Ripple(location: location, isIdentity: false),
                identity: Ripple(location: location, isIdentity: true)
            ),
            removal: .modifier(
                active: IdentityDelayTransition(opacity: 0.99),
                identity: IdentityDelayTransition(opacity: 1)
            )
        )
    }

    // This transition is suited for views inside an if statement or overlays to a
    // NavigationStack and tied to an if statement.
    static func reverseRipple(location: CGPoint) -> AnyTransition {
        .modifier(
            active: Ripple(location: location, isIdentity: false),
            identity: Ripple(location: location, isIdentity: true)
        )
    }
}

struct IdentityDelayTransition: ViewModifier {
    var opacity: Double

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
    }
}

struct Ripple: ViewModifier {
    var location: CGPoint
    var isIdentity = false

    func body(content: Content) -> some View {
        content
            .mask(alignment: .topLeading) {
                rippleShape
                    .ignoresSafeArea()
            }
    }

    var rippleShape: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let progress = isIdentity ? 1.0 : 0.0

            let circleSize: CGFloat = 50
            let circleRadius = circleSize / 2

            let fillCircleScale: CGFloat = max(size.width, size.height) / circleRadius + 4
            let defaultScale: CGFloat = isIdentity ? 1.0 : 0.0

            ZStack(alignment: .center) {
                Circle()
                    .frame(width: circleSize, height: circleSize)

                Circle()
                    .frame(width: circleSize + 10, height: circleSize + 10)
                    .blur(radius: 3)

                Circle()
                    .frame(width: circleSize + 20, height: circleSize + 20)
                    .blur(radius: 7)

                Circle()
                    .opacity(0.5)
                    .frame(width: circleSize + 30, height: circleSize + 30)
                    .blur(radius: 7)

            }
            .frame(width: circleSize, height: circleSize)
            .compositingGroup()
            .scaleEffect(defaultScale + progress * fillCircleScale, anchor: .center)
            .offset(x: location.x - circleRadius, y: location.y - circleRadius)
        }
    }
}

#Preview {
    RippleView()
}
