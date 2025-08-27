//
//  SlackHeaderPopOutView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 27.08.25.
//

import SwiftUI

struct SlackHeaderPopOutView<Header: View, Content: View>: View {
    @ViewBuilder var header: (Bool) -> Header
    @ViewBuilder var content: (Bool) -> Content

    // View properties
    @State private var sourceRect: CGRect = .zero
    @State private var showFullScreenCover = false
    @State private var animateView = false

    var body: some View {
        header(animateView)
            .background(solidBackground(color: .gray, opacity: 0.1))
            .clipShape(.rect(cornerRadius: 10))
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { newValue in
                sourceRect = newValue
            }
            .contentShape(.rect)
            .opacity(showFullScreenCover ? 0 : 1)
            .onTapGesture {
                toggleFullScreenCover()
            }
            .fullScreenCover(isPresented: $showFullScreenCover) {
                PopOutOverlayView(
                    sourceRect: $sourceRect,
                    animateView: $animateView,
                    header: header,
                    content: content
                ) {
                    withAnimation(.easeInOut(duration: 0.25), completionCriteria: .removed) {
                        animateView = false
                    } completion: {
                        toggleFullScreenCover()
                    }
                }
            }
    }

    private func toggleFullScreenCover() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            showFullScreenCover.toggle()
        }
    }
}

private extension View {
    func solidBackground(color: Color, opacity: CGFloat) -> some View {
        Rectangle()
            .fill(.background)
            .overlay {
                Rectangle()
                    .fill(color.opacity(opacity))
            }
    }
}

private struct PopOutOverlayView<Header: View, Content: View>: View {
    @Binding var sourceRect: CGRect
    @Binding var animateView: Bool
    @ViewBuilder var header: (Bool) -> Header
    @ViewBuilder var content: (Bool) -> Content
    var dismissAction: () -> Void

    @State private var edgeInsets: EdgeInsets = .init()
    @State private var scale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                if animateView {
                    Button(action: dismissAction) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.primary)
                            .contentShape(.rect)
                    }
                }
                header(animateView)
            }

            if animateView {
                content(animateView)
                    .transition(.blurReplace)
            }
        }
        // Taking the whole available space when expanded
        .frame(maxWidth: animateView ? .infinity : nil)
        .padding(animateView ? 15 : 0)
        .background {
            ZStack {
                solidBackground(color: .gray, opacity: 0.1)
                    .opacity(!animateView ? 1 : 0)

                Rectangle()
                    .fill(.background)
                    .opacity(animateView ? 1 : 0)
            }
        }
        .clipShape(.rect(cornerRadius: animateView ? 20 : 10))
        .scaleEffect(scale, anchor: .top)
        .frame(
            width: animateView ? nil : sourceRect.width,
            height: animateView ? nil : sourceRect.height
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .offset(
            x: animateView ? 0 : sourceRect.minX,
            y: animateView ? 0 : sourceRect.minY
        )
        .padding(animateView ? 15 : 0)
        .padding(.top, animateView ? edgeInsets.top : 0)
        .ignoresSafeArea()
        .presentationBackground {
            GeometryReader { geo in
                let size = geo.size
                Rectangle()
                    .fill(.black.opacity(animateView ? 0.4 : 0))
                    .onTapGesture {
                        dismissAction()
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                let height = value.translation.height
                                let scale = height / size.height
                                self.scale = 1 + (scale * 0.1)
                            })
                            .onEnded({ value in
                                let velocityHeight = value.velocity.height / 5
                                let height = value.translation.height + velocityHeight
                                let scale = height / size.height
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    self.scale = 1.0
                                }

                                if -scale > 0.5 {
                                    dismissAction()
                                }
                            })
                    )
            }
        }
        .onGeometryChange(for: EdgeInsets.self) { proxy in
            proxy.safeAreaInsets
        } action: { newValue in
            guard !animateView else { return }
            edgeInsets = newValue
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.25)) {
                    animateView = true
                }
            }
        }
    }
}

private struct SlackContentView: View {
    @Namespace private var animation
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: "chevron.left")
                    .font(.title3)

                SlackHeaderPopOutView { isExpanded in
                    // Slack Dummy Header View
                    HStack(spacing: 10) {
                        ZStack {
                            if !isExpanded {
                                Image(systemName: "number")
                                    .fontWeight(.semibold)
                                    .matchedGeometryEffect(id: "#", in: animation)
                            }
                        }
                        .frame(width: 20)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 0) {
                                if isExpanded {
                                    Image(systemName: "number")
                                        .matchedGeometryEffect(id: "#", in: animation)
                                        .scaleEffect(0.8)
                                }

                                Text("general")
                            }
                            .fontWeight(.semibold)
                            Text("1,024 members")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .offset(x: isExpanded ? -30 : 0)
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                } content: { isExpanded in
                    // Let's add some dummy views
                    VStack(spacing: 12) {
                        ForEach(1...4, id: \.self) { index in
                            Button {

                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "bell")
                                        .frame(width: 25)

                                    Text("Lorem ipsum")

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .foregroundStyle(Color.primary)
                            }
                        }
                    }
                }

                Image(systemName: "airpods.max")
                    .font(.title3)

            }

            Spacer()
        }
        .padding(15)
    }
}

#Preview {
    SlackContentView()
}
