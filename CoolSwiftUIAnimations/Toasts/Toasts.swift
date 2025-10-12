//
//  Toasts.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 11.10.25.
//

import SwiftUI

private struct Toast: Identifiable {
    let id = UUID().uuidString
    var content: AnyView

    var offsetX: CGFloat = 0
    var isDeleting = false

    init(@ViewBuilder content: @escaping (String) -> some View) {
        self.content = .init(content(id))
    }
}

// MARK: - View Extension

private extension View {
    @ViewBuilder
    func interactiveToasts(_ toasts: Binding<[Toast]>) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                ToastsView(toasts: toasts)
            }
    }
}

private struct ToastsView: View {
    @Binding var toasts: [Toast]

    // View Properties
    @State private var isExpanded: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if isExpanded{
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isExpanded = false
                    }
            }

            let layout = isExpanded ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(ZStackLayout())

            layout {
                ForEach($toasts) { $toast in
                    // Reverse index for stack to go upwards
                    let index = (toasts.count - 1) - (toasts.firstIndex(where: { $0.id == toast.id }) ?? 0)
                    toast.content
                        .offset(x: toast.offsetX)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let offsetX = value.translation.width < 0 ?
                                        value.translation.width : 0
                                    toast.offsetX = offsetX
                                }
                                .onEnded { value in
                                    let offsetX = value.translation.width + (value.velocity.width / 2)

                                    if offsetX < -200 {
                                        $toasts.delete(toast.id)
                                    } else {
                                        withAnimation(.bouncy) {
                                            toast.offsetX = 0
                                        }
                                    }
                                }
                        )
                        .visualEffect { [isExpanded] content, proxy in
                            content
                                .scaleEffect(isExpanded ? 1 : scale(index), anchor: .bottom)
                                .offset(y: isExpanded ? 0: offsetY(index))
                        }
                        .zIndex(toast.isDeleting ? 1000 : 0)
                        // This way, toasts are removed even when we add very small toasts
                        .frame(maxWidth: .infinity)
                        .transition(
                            .asymmetric(
                                insertion: .offset(y: 100),
                                removal: .move(edge: .leading)
                            )
                        )
                }
            }
            .onTapGesture {
                isExpanded.toggle()
            }
        }
        .animation(.bouncy, value: isExpanded)
        .padding(.bottom, 15)
        .onChange(of: toasts.isEmpty) { oldValue, newValue in
            if newValue { isExpanded = false }
        }
    }

    nonisolated func offsetY(_ index: Int) -> CGFloat {
        let offset = min(CGFloat(index) * 15, 30)

        return -offset
    }

    nonisolated func scale(_ index: Int) -> CGFloat {
        let scale = min(CGFloat(index) * 0.1, 1)

        return 1 - scale
    }
}

// MARK: - Binding extension

private extension Binding<[Toast]> {
    func delete(_ id: String) {
        if let toast = first(where: { $0.id == id }) {
            toast.wrappedValue.isDeleting = true
        }

        withAnimation(.bouncy) {
            wrappedValue.removeAll { $0.id == id }
        }
    }
}

// MARK: - Content View

private struct ToastsContentView: View {
    @State private var toasts: [Toast] = []

    var body: some View {
        NavigationStack {
            List {
                Text("To be continued...")
            }
            .navigationTitle("Toasts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Show", action: showToast)
                }
            }
        }
        .interactiveToasts($toasts)
    }

    func showToast() {
        withAnimation(.bouncy) {
            let toast = Toast { id in
                toastView(id: id)
            }
            toasts.append(toast)
        }
    }

    // Your custom toast view
    @ViewBuilder
    func toastView(id: String) -> some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up.fill")

                Text("Hello world!")
                    .font(.callout)

                Spacer(minLength: 0)

                Button {
                    $toasts.delete(id)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                }
            }
        }
        .foregroundStyle(Color.primary)
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background {
            Capsule()
                .fill(.background)
            // Shadow
                .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                .shadow(color: .black.opacity(0.06), radius: 3, x: 1, y: 3)
        }
        .padding(.horizontal, 15)
    }
}

// MARK: - Preview

#Preview {
    ToastsContentView()
}
