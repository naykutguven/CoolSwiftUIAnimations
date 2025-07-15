//
//  MessageMenuView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 15.07.25.
//

import SwiftUI

// Wrapper to show menu view on top of the wrapped view
private struct MessageMenuView<Content: View>: View {
    @Binding var config: MenuConfig
    @ViewBuilder var content: Content
    @MenuActionBuilder var actions: [MenuAction]

    // View properties
    @State private var animateContent = false
    @State private var animateLabels = false

    // For resetting the scroll position once the menu is closed
    @State private var activeItemID: UUID?

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .opacity(animateContent ? 1 : 0)
                    .allowsHitTesting(false)
            }
            .overlay {
                if animateContent {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .contentShape(.rect)
                        .onDisappear {
                            config.hideSourceView = false
                            activeItemID = actions.first?.id
                        }
                }
            }
            .overlay {
                GeometryReader {
                    menuScrollView($0)

                    if config.hideSourceView {
                        config.sourceView
                            .scaleEffect(animateContent ? 15.0 : 1, anchor: .bottom)
                            .offset(
                                x: config.sourceLocation.minX,
                                y: config.sourceLocation.minY
                            )
                            .opacity(animateContent ? 0.25 : 1.0)
                            .blur(radius: animateContent ? 130 : 0)
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                    }
                }
                .opacity(config.hideSourceView ? 1 : 0)
            }
            .onChange(of: config.showMenu) { oldValue, newValue in
                if newValue {
                    config.hideSourceView = true
                }

                withAnimation(.smooth(duration: 0.3)) {
                    animateContent = newValue
                }

                withAnimation(.easeInOut(duration: newValue ? 0.35 : 0.15)) {
                    animateLabels = newValue
                }

            }
    }

    @ViewBuilder
    func menuScrollView(_ proxy: GeometryProxy) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(actions) { action in
                    menuActionView(action: action)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                Rectangle()
                    .foregroundStyle(.clear)
                    .frame(width: proxy.size.width, height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom)
                    .contentShape(.rect)
                    .onTapGesture {
                        guard config.showMenu else { return }
                        config.showMenu = false
                    }
                    .visualEffect { content, proxy in
                        content
                            .offset(
                                x: -proxy.frame(in: .global).minX,
                                y: -proxy.frame(in: .global).minY
                            )
                    }
            }
        }
        .safeAreaPadding(.vertical, 20)
        .safeAreaPadding(.top, (proxy.size.height - 70) / 2)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $activeItemID, anchor: .top)
        .allowsHitTesting(config.showMenu)
    }

    @ViewBuilder
    func menuActionView(action: MenuAction) -> some View {
        let sourceLocation = config.sourceLocation

        HStack(spacing: 20) {
            Image(systemName: action.symbolImage)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background {
                    Circle()
                        .fill(.background)
                        .shadow(radius: 1.5)
                }
                .scaleEffect(animateContent ? 1.0 : 0.6 )
                .opacity(animateContent ? 1.0 : 0.0)
                .blur(radius: animateContent ? 0 : 4)

            Text(action.text)
                .font(.callout)
                .fontWeight(.medium)
                .lineLimit(1)
                .opacity(animateLabels ? 1.0 : 0.0)
                .blur(radius: animateLabels ? 0 : 4)
        }
        .visualEffect({ [animateContent] content, proxy in
            content
                .offset(
                    x: animateContent ? 0 : sourceLocation.minX - proxy.frame(in: .global).minX,
                    y: animateContent ? 0 : sourceLocation.minY - proxy.frame(in: .global).minY
                )

        })
        .frame(height: 70)
        .contentShape(.rect)
        .onTapGesture {
            action.action()
        }
    }
}

private struct MessageContentView: View {
    @State private var config = MenuConfig(symbolImage: "plus")

    var body: some View {
        MessageMenuView(config: $config) {
            // Your content here
            NavigationStack {
                ScrollView {

                }
                .navigationTitle("Messages")
                .safeAreaInset(edge: .bottom) {
                    bottomBar()
                }
            }
        } actions: {
            MenuAction(symbolImage: "camera", text: "Camera")
            MenuAction(symbolImage: "photo.on.rectangle.angled", text: "Photos")
            MenuAction(symbolImage: "face.smiling", text: "React")
            MenuAction(symbolImage: "waveform", text: "Audio")
            MenuAction(symbolImage: "apple.logo", text: "App Store")
            MenuAction(symbolImage: "location", text: "Location")
            MenuAction(symbolImage: "music.note", text: "Music")
            MenuAction(symbolImage: "video.badge.waveform", text: "Facetime")
            MenuAction(symbolImage: "heart", text: "Like")
        }

    }

    @ViewBuilder
    func bottomBar() -> some View {
        HStack(spacing: 12) {
            MenuSourceButton(config: $config) {
                Image(systemName: "plus")
                    .font(.title3)
                    .frame(width: 35, height: 35)
                    .background {
                        Circle()
                            .fill(.gray.opacity(0.25))
                            .background(.background, in: .circle)
                    }
            } onTap: {
                print("Plus button tapped")
            }

            TextField("Message", text: .constant(""))
                .padding(.vertical, 8)
                .padding(.horizontal, 15)
                .background {
                    Capsule()
                        .strokeBorder(.gray.opacity(0.3), lineWidth: 1.5)
                }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}

// MARK: - Source Button

private struct MenuSourceButton<Content: View>: View {
    @Binding var config: MenuConfig
    @ViewBuilder var content: Content

    var onTap: () -> Void

    var body: some View {
        content
            .contentShape(.rect)
            .onTapGesture {
                onTap()
                config.sourceView = .init(content)
                config.showMenu.toggle()
            }
            .onGeometryChange(for: CGRect.self) { geometry in
                geometry.frame(in: .global)
            } action: { newValue in
                config.sourceLocation = newValue
            }
            // Hiding source view when hideSourceView is true
            // why 0.01?
            .opacity(config.hideSourceView ? 0.01 : 1)
    }
}

// MARK: - Menu Config

private struct MenuConfig {
    var symbolImage: String
    var sourceLocation: CGRect = .zero
    var showMenu: Bool = false
    var sourceView: AnyView = .init(EmptyView())
    var hideSourceView: Bool = false
}

// MARK: - Menu Actions

private struct MenuAction: Identifiable {
    let id = UUID()
    var symbolImage: String
    var text: String
    var action: () -> Void = {}
}

@resultBuilder
private struct MenuActionBuilder {
    static func buildBlock(_ components: MenuAction...) -> [MenuAction] {
        components.compactMap { $0 }
    }
}

#Preview {
    MessageContentView()
}
