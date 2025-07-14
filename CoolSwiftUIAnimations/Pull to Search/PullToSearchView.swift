//
//  PullToSearchView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 14.07.25.
//

import SwiftUI

struct PullToSearchView: View {
    @State private var offsetY: CGFloat = 0
    @FocusState private var isExpanded: Bool

    private var progress: CGFloat {
        max(min(offsetY / 100, 1), 0)
    }

    var body: some View {
        ScrollView {
            // Your scroll content
            dummyScrollContent()
                .offset(y: isExpanded ? -offsetY : 0)
            // Attach it to the main scroll content
            // This is for iOS 17+. For iOS 18+, we can use onScrollGeometryChange
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.frame(in: .scrollView(axis: .vertical)).minY
                } action: { newValue in
                    offsetY = newValue
                }
        }
        // Search content container
        .overlay {
            Rectangle()
                .fill(.ultraThinMaterial)
                .backgroundStyle(.background.opacity(0.25))
                .ignoresSafeArea()
                .overlay  {
                    // Expanded search content
                    ExpandedSearchView()
                        .offset(y: isExpanded ? 0 : 70)
                        .opacity(isExpanded ? 1 : 0)
                        .allowsHitTesting(isExpanded)
                }
                .opacity(isExpanded ? 1 : progress)
        }
        .safeAreaInset(edge: .top) {
            headerView()
        }
        .scrollTargetBehavior(OnScrollEnd { dy in
            print(dy, offsetY)
            // If user is at the top of the scroll content and either pulled down 100 points
            // (slowly) or pulled down more than 1.5 points per second, we trigger the behavior.
            if offsetY > 100 || (-dy > 1.5 && offsetY > 0) {
                isExpanded = true
            }
        })
        .animation(.smooth(duration: 0.3), value: isExpanded)
    }

    @ViewBuilder
    func headerView() -> some View {
        HStack(spacing: 20) {
            if !isExpanded {
                Button {

                } label: {
                    Image(systemName: "slider.horizontal.below.square.filled.and.square")
                        .font(.title2)
                }
                .transition(.blurReplace)
            }

            TextField("Search App", text: .constant(""))
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background {
                    ZStack {
                        Rectangle()
                            .fill(.gray.opacity(0.2))
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    }
                    .clipShape(.rect(cornerRadius: 15))
                }
                .focused($isExpanded)

            Button {

            } label: {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
            }
            .opacity(isExpanded ? 0 : 1)
            .overlay(alignment: .trailing) {
                Button("Cancel") {
                    isExpanded = false
                }
                .fixedSize()
                .opacity(isExpanded ? 1 : 0)
            }
            .padding(.leading, isExpanded ? 20 : 0)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .padding(.bottom, 5)
        .background {
            Rectangle()
                .fill(.background)
                .ignoresSafeArea()
            // Hiding the background when the search is expanded
                .opacity(progress == 0 && !isExpanded ? 1 : 0)
        }
    }

    @ViewBuilder
    func dummyScrollContent() -> some View {
        VStack(spacing: 15) {
            HStack(spacing: 30) {
                ForEach(0..<4) { index in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.randomSystem.gradient)
                }
            }
            .frame(height: 60)

            VStack(alignment: .leading, spacing: 25) {
                Text("Your Favorites")
                    .foregroundStyle(.gray)

                Text("Start adding your favorites\nto show up here!")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(.top, 30)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
    }
}

private struct ExpandedSearchView: View {
    var body: some View {
        List {
            let colors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple]

            ForEach(colors, id: \.self) { color in
                Section(String(describing: color).capitalized) {
                    ForEach(1...5, id: \.self) { index in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(color.gradient)
                                .frame(width: 40, height: 40)

                            Text("Item \(index)")
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .clipped()
    }
}

// Triggered when the user releases the scrollview
struct OnScrollEnd: ScrollTargetBehavior {
    // Return Velocity
    var onEnd: (CGFloat) -> Void

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let dy = context.velocity.dy
        DispatchQueue.main.async {
            onEnd(dy)
        }
    }
}

#Preview {
    PullToSearchView()
}
