//
//  UniversalOverlay.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 11.10.25.
//

import SwiftUI

private struct UniversalOverlayViews: View {
    @Environment(UniversalOverlayProperties.self) private var properties

    var body: some View {
        ZStack {
            ForEach(properties.views) { overlay in
                overlay.view
            }
        }
    }
}

// MARK: - Root View

// To make this work, we need to wrap the root view of the app with this RootView.
private struct RootView<Content: View>: View {
    @ViewBuilder var content: Content
    var properties = UniversalOverlayProperties()

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .environment(properties)
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   properties.window == nil {
                    let window = PassThroughWindow(windowScene: windowScene)
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    // Setting up SwiftUI based root view controller
                    let rootViewController = UIHostingController(
                        rootView: UniversalOverlayViews().environment(properties)
                    )
                    rootViewController.view.backgroundColor = .clear
                    window.rootViewController = rootViewController

                    properties.window = window
                }
            }
    }

}

// MARK: - View Extensions

private extension View {
    @ViewBuilder
    func universalOverlay<Content: View>(
        animation: Animation = .snappy,
        show: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .modifier(
                UniversalOverlayModifier(
                    animation: animation,
                    show: show,
                    viewContent: content
                )
            )
    }
}

// Shared Universal Overlay Properties
@Observable
class UniversalOverlayProperties {
    var window: UIWindow?
    var views: [OverlayView] = []

    struct OverlayView: Identifiable {
        var id = UUID().uuidString
        var view: AnyView
    }
}

// MARK: - View Modifier

private struct UniversalOverlayModifier<ViewContent: View>: ViewModifier {
    var animation: Animation
    @Binding var show: Bool
    @ViewBuilder var viewContent: ViewContent

    // Local View Properties
    @Environment(UniversalOverlayProperties.self) private var properties
    @State private var viewID: String?

    func body(content: Content) -> some View {
        content
            .onChange(of: show) { oldValue, newValue in
                if newValue {
                    addView()
                } else {
                    removeView()
                }
            }
    }

    private func addView() {
        if properties.window != nil, viewID == nil {
            viewID = UUID().uuidString
            guard let viewID else { return }

            withAnimation(animation) {
                properties.views.append(.init(id: viewID, view: AnyView(viewContent)))
            }
        }
    }

    private func removeView() {
        if let viewID {
            withAnimation(animation) {
                properties.views.removeAll { $0.id == viewID }
            }

            self.viewID = nil
        }
    }
}

// MARK: - Custom Pass Through Window

private class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event),
              let rootView = rootViewController?.view
        else { return nil }


        // if you support pre-iOS 18
        // return hitView == rootView ? nil : hitView

        // iOS 18 and later
        for subView in rootView.subviews.reversed() {
            let pointInSubview = subView.convert(point, from: rootView)
            if subView.hitTest(pointInSubview, with: event) == subView {
                return hitView
            }
        }

        return nil
    }
}

// MARK: - Content View

private struct UniversalOverlayContentView: View {
    @State private var show: Bool = false
    @State private var showSheet: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Button("Floating Video View") {
                    show.toggle()
                }
                .universalOverlay(show: $show) {
                    // Your custom overlay content here
                    Circle()
                        .fill(.red)
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            print("Tapped")
                        }
                }

                Button("Show dummy sheet") {
                    showSheet.toggle()
                }
            }
            .navigationTitle("Universal Overlay")
        }
        .sheet(isPresented: $showSheet) {
            Text("Hello, World!")
        }
    }
}

// MARK: - Previews

#Preview {
    // We need to wrpa like this to make it work.
    RootView {
        UniversalOverlayContentView()
    }
}
