//
//  TabViewOffsetReader.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 13.10.25.
//

import SwiftUI

private enum DummyTab: String, CaseIterable {
    case home = "Home"
    case chats = "Chats"
    case calls = "Calls"
    case settings = "Settings"

    var color: Color {
        switch self {
        case .home: return .red
        case .chats: return .blue
        case .calls: return .black
        case .settings: return .purple
        }
    }
}

// MARK: - This is not working. Prefer "PreferenceKey" based custom ScrollView solutions instead.

//private struct TabContentView: View {
//    @State private var activeTab: DummyTab = .home
//    var offsetObserver = PageOffsetObserver()
//
//    var body: some View {
//        VStack(spacing: 15) {
//            TabView(selection: $activeTab) {
//                DummyTab.home.color
//                    .tag(DummyTab.home)
//                    // We need to attach our custom UIViewRepresentable to find the underlying UICollectionView
//                    .background {
//                        // To make sure we add observer only once.
//                        FindCollectionView {
//                            offsetObserver.collectionView = $0
//                        }
//                    }
//
//                DummyTab.chats.color
//                    .tag(DummyTab.chats)
//
//                DummyTab.calls.color
//                    .tag(DummyTab.calls)
//
//                DummyTab.settings.color
//                    .tag(DummyTab.settings)
//            }
//            // Already horizontally scrollable with this modifier
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            overlay {
//                Text("Offset: \(offsetObserver.offset, specifier: "%.2f")")
//            }
//        }
//    }
//}
//
//// MARK: - Observer
//
///// SwiftUI TabView is built on top of UIKit's UICollectionView. Here we are leveraging that.
//@MainActor @Observable
//private class PageOffsetObserver: NSObject {
//    var collectionView: UICollectionView? {
//        didSet { rebindObservation() }
//    }
//    var offset: CGFloat = 0.0
//
//    private var observation: NSKeyValueObservation?
//
//    deinit {
//        observation = nil // invalidates safely
//    }
//
//    private func rebindObservation() {
//        // Tear down old observation
//        observation = nil
//
//        // Set up new observation on main thread
//        guard let collectionView else { return }
//        observation = collectionView.observe(\.contentOffset, options: [.new]) { [weak self] cv, _ in
//            self?.offset = cv.contentOffset.x
//        }
//    }
//}
//
//private struct FindCollectionView: UIViewRepresentable {
//    var result: (UICollectionView) -> Void
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        view.backgroundColor = .clear
//
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
//            if let collectionView = view.collectionSuperView {
////                print(collectionView)
//                result(collectionView)
//            }
//        }
//
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {}
//}
//
//// MARK: - Helper extension
//
//private extension UIView {
//    var collectionSuperView: UICollectionView? {
//        if let collectionView = superview as? UICollectionView {
//            return collectionView
//        }
//
//        return superview?.collectionSuperView
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    TabContentView()
//}
