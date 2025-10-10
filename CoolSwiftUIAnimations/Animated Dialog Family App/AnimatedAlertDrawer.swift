//
//  AnimatedAlertDrawer.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 08.10.25.
//

import SwiftUI

private struct DrawerConfig {
    var tint: Color
    var foreground: Color
    var clipShape: AnyShape
    var animation: Animation

    fileprivate(set) var isPresented: Bool = false
    fileprivate(set) var hideSourceButton: Bool = false
    fileprivate(set) var sourceRect: CGRect = .zero

    init(
        tint: Color = .red,
        foreground: Color = .white,
        clipShape: AnyShape = .init(.capsule),
        animation: Animation = .snappy(duration: 0.35)
    ) {
        self.tint = tint
        self.foreground = foreground
        self.clipShape = clipShape
        self.animation = animation
    }
}

private struct AnimatedAlertDrawerButton: View {
    var title: String
    @Binding var config: DrawerConfig

    var body: some View {
        Button {
            config.hideSourceButton = true
            withAnimation(config.animation) {
                config.isPresented = true
            }
        } label: {
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(config.foreground)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(config.tint, in: config.clipShape)
        }
        .buttonStyle(ScaledButtonStyle())
        .opacity(config.hideSourceButton ? 0 : 1)
        // onGeometryChange is very useful here to capture the button's frame
        .onGeometryChange(for: CGRect.self) { geometry in
            // geometry proxy of the button
            geometry.frame(in: .global)
        } action: { newValue in
            config.sourceRect = newValue
        }

    }
}

// MARK: - Drawer Overlay View

private extension View {
    @ViewBuilder
    func alertDrawer<Content: View>(
        config: Binding<DrawerConfig>,
        primaryTitle: String,
        secondaryTitle: String,
        onPrimaryClick: @escaping () -> Void,
        onSecondaryClick: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                GeometryReader { geometry in
                    let isPresented = config.wrappedValue.isPresented

                    // Covers the entire screen. We are adding tap-outside-to-close
                    // functionality here.
                    ZStack {
                        if isPresented {
                            Rectangle()
                                .fill(.black.opacity(0.5))
                                .transition(.opacity)
                                .onTapGesture {
                                    withAnimation(
                                        config.wrappedValue.animation,
                                        completionCriteria: .logicallyComplete
                                    ) {
                                        config.wrappedValue.isPresented = false
                                    } completion: {
                                        config.wrappedValue.hideSourceButton = false
                                    }
                                }
                        }

                        if config.wrappedValue.hideSourceButton {
                            AlertDrawerContentView(
                                proxy: geometry,
                                primaryTitle: primaryTitle,
                                secondaryTitle: secondaryTitle,
                                onPrimaryClick: onPrimaryClick,
                                onSecondaryClick: onSecondaryClick,
                                config: config,
                                content: content
                            )
                            .transition(.identity)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .topLeading
                            )
                        }
                    }
                    .ignoresSafeArea()
                }
            }
    }
}

private struct AlertDrawerContentView<Content: View>: View {
    var proxy: GeometryProxy
    var primaryTitle: String
    var secondaryTitle: String
    var onPrimaryClick: () -> Void
    var onSecondaryClick: () -> Void

    @Binding var config: DrawerConfig
    @ViewBuilder var content: Content

    var body: some View {
        let isPresented = config.isPresented
        let sourceRect = config.sourceRect
        let maxY = proxy.frame(in: .global).maxY

        // The actual alert content
        VStack(spacing: 15) {
            content
                .overlay(alignment: .topTrailing) {
                    Button {

                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.primary, .gray.opacity(0.15))
                    }

                }
                .compositingGroup()
                .opacity(isPresented ? 1 : 0)

            HStack(spacing: 10) {
                GeometryReader { geo in
                    Button {
                        onSecondaryClick()
                    } label: {
                        Text(secondaryTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThinMaterial, in: config.clipShape)
                    }
                    .offset(fixedLocation(geo))
                    .opacity(isPresented ? 1 : 0)
                }
                .frame(height: config.sourceRect.height)

                GeometryReader { geo in
                    Button {
                        onPrimaryClick()
                    } label: {
                        Text(primaryTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(config.foreground)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(config.tint, in: config.clipShape)
                    }
                    .frame(
                        width: isPresented ? nil : sourceRect.width,
                        height: isPresented ? nil : sourceRect.height
                    )
                    .offset(fixedLocation(geo))
                }
                .frame(height: config.sourceRect.height)
                .zIndex(1)
            }
            .buttonStyle(ScaledButtonStyle())
        }
        .padding([.horizontal, .top], 20)
        .padding(.bottom, 15)
        .frame(
            width: isPresented ? nil : sourceRect.width,
            height: isPresented ? nil : sourceRect.height,
            alignment: .top
        )
        .background(.background)
        .clipShape(.rect(cornerRadius: sourceRect.height / 2))
        // some shadows
        .shadow(color: .black.opacity(isPresented ? 0.1 : 0), radius: 5, x: 5, y: 5)
        .shadow(color: .black.opacity(isPresented ? 0.1 : 0), radius: 5, x: -5, y: -5)
        .padding(.horizontal, isPresented ? 20 : 0)
        .visualEffect { content, proxy in
            content
                .offset(
                    x: isPresented ? 0 : sourceRect.minX,
                    y: (isPresented ? maxY : sourceRect.maxY) - proxy.size.height
                )
        }
    }

    func fixedLocation(_ proxy: GeometryProxy) -> CGSize {
        let isPresented = config.isPresented
        let sourceRect = config.sourceRect

        return CGSize(
            width: isPresented ? 0 : (sourceRect.minX - proxy.frame(in: .global).minX),
            height: isPresented ? 0 : (sourceRect.minY - proxy.frame(in: .global).minY)
        )
    }
}

// MARK: - Button Style

private struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Content View

private struct AnimatedAlertDrawerContentView: View {
    @State private var config = DrawerConfig()

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                AnimatedAlertDrawerButton(title: "Continue", config: $config)
            }
            .padding()
            .navigationTitle("Animated Alert Drawer")
        }
        .alertDrawer(
            config: $config,
            primaryTitle: "Continue",
            secondaryTitle: "Cancel") {

            } onSecondaryClick: {

            } content: {
                // Some dummy content
                VStack(alignment: .leading, spacing: 15) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Are you sure?")
                        .font(.title2.bold())

                    Text("You haven't saved your changes yet. If you leave, your changes will be lost.")
                        .foregroundStyle(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 300)
                }
            }

    }
}


// MARK: - Previews

#Preview {
    AnimatedAlertDrawerContentView()
}
