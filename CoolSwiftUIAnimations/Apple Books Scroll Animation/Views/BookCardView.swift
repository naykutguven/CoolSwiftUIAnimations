//
//  BookCardView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 28.06.25.
//

import SwiftUI

struct BookCardView: View {
    var book: Book
    var size: CGSize
    var parentHorizontalPadding: CGFloat = 15.0

    var onPageScrolled: ((Bool) -> Void)?

    /// State for scroll animation
    @State private var scrollGeometry: ScrollGeometry = .init(
        contentOffset: .zero,
        contentSize: .zero,
        contentInsets: .init(),
        containerSize: .zero
    )

    @State private var scrollPosition: ScrollPosition = .init()
    @State private var isPageScrolled = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                topCardView()
                    .containerRelativeFrame(.vertical) { length, _ in
                        length * 0.7
                    }
                otherTextContent
                    .padding(.horizontal, 15)
                // The content's maxWidth remains the same even when the scroll position and
                // the container's padding change.
                    .frame(maxWidth: size.width - 30 - parentHorizontalPadding * 2)
                    .padding(.bottom, 50)
            }
            .padding(.horizontal, -parentHorizontalPadding * scrollGeometry.topInsetProgress)
        }
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
        // where the magic happens
        .scrollPosition($scrollPosition)
        .onScrollGeometryChange(for: ScrollGeometry.self, of: { $0 }, action: { oldValue, newValue in
            scrollGeometry = newValue
            isPageScrolled = newValue.contentOffset.y > 0
        })
        // This resets the scroll position to the top inset when the user scrolls slightly
        // within the top inset range, giving a spring-like effect.
        .scrollTargetBehavior(BookScrollEnd(topInset: scrollGeometry.contentInsets.top))
        .onChange(of: isPageScrolled, { oldValue, newValue in
            onPageScrolled?(newValue)
        })
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 15, topTrailingRadius: 15)
                .fill(.background)
                .ignoresSafeArea(.all, edges: .bottom)
                .offset(y: scrollGeometry.offsetY > 0 ? 0 : -scrollGeometry.offsetY)
            // Background needs the same dynamic horizontal padding as the VStack
                .padding(.horizontal, -parentHorizontalPadding * scrollGeometry.topInsetProgress)
        }
    }


    @ViewBuilder
    func topCardView() -> some View {

        VStack(spacing: 15) {
            fixedHeaderView()

            Image(book.thumbnail)
                .resizable()
                .scaledToFit()
                .padding(.top, 20)

            Text(book.title)
                .font(.title2)
                .bold()
                .fontDesign(.serif)

            Button {

            } label: {
                HStack(spacing: 6) {
                    Text(book.author)

                    Image(systemName: "chevron.right")
                        .font(.callout)
                }
            }
            .padding(.top, -5)

            Label(book.rating, systemImage: "star.fill")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("Book")
                        .fontWeight(.semibold)

                    Image(systemName: "info.circle")
                        .font(.caption)
                }

                Text("157 pages")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    Button {

                    } label: {
                        Label("Sample", systemImage: "book.pages")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                    }

                    Button {

                    } label: {
                        Text("Get")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                    }
                }
                .tint(.white.opacity(0.2))
                .buttonStyle(.borderedProminent)
                .padding(.top, 5)
            }
            .padding(15)
            .background(.white.opacity(0.2), in: .rect(cornerRadius: 20))
        }
        .foregroundStyle(.white)
        .padding(15)
        .frame(maxWidth: size.width - parentHorizontalPadding * 2)
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(book.color.gradient)
        }
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 15,
                topTrailingRadius: 15
            )
        )
    }

    @ViewBuilder
    private var otherTextContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("From the Publisher")
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.serif)

            Text("""
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore
 et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
 nisi ut aliquip ex ea commodo consequat.
"""
            )
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .lineLimit(5)

            Text("""
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore
 et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
 nisi ut aliquip ex ea commodo consequat.
"""
            )
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .lineLimit(5)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    func fixedHeaderView() -> some View {
        HStack(spacing: 15) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    scrollPosition.scrollTo(edge: .top)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
            }

            Spacer()

            Button {

            } label: {
                Image(systemName: "plus.circle.fill")
            }

            Button {

            } label: {
                Image(systemName: "ellipsis.circle.fill")
            }
        }
        .buttonStyle(.plain)
        .font(.title)
        .foregroundStyle(.white, .white.tertiary)
        .padding(.horizontal, -parentHorizontalPadding * scrollGeometry.topInsetProgress)
        .offset(y: scrollGeometry.offsetY < 20 ? 0 : scrollGeometry.offsetY - 20)
        .zIndex(1000)
    }
}

struct BookScrollEnd: ScrollTargetBehavior {
    var topInset: CGFloat

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        if target.rect.minY < topInset {
            target.rect.origin = .zero
        }
    }
}

extension ScrollGeometry {
    var offsetY: CGFloat {
        // If contentInsets.top is non-zero, the initial contentOffset.y  will be negative.
        print("Content Offset Y: \(contentOffset.y)")
        print("Content Insets Top: \(contentInsets.top)")
        return contentOffset.y + contentInsets.top
    }

    var topInsetProgress: CGFloat {
        guard contentInsets.top > 0 else { return 0 }
        let progress = max(min(offsetY / contentInsets.top, 1), 0)
        print("Top Inset Progress: \(progress)")
        return progress
    }
}

#Preview {
    GeometryReader { proxy in
        BookCardView(book: Book.sampleBooks[0], size: proxy.size)
            .padding(.horizontal, 15)
    }
    .background(.gray.opacity(0.15))
}
