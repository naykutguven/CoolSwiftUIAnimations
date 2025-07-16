//
//  TaskManagementContentView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 16.07.25.
//

import SwiftUI

struct TaskManagementContentView: View {
    @State private var currentWeek: [Day] = Date.currentWeek.map { Day(date: $0) }
    @State private var selectedDate: Date?

    // For MatchedGeometry Effect
    @Namespace private var namespace

    var body: some View {
        VStack(spacing: 0) {
            headerView()
                .environment(\.colorScheme, .dark)

            GeometryReader { proxy in
                let size = proxy.size

                // Sectioned scroll view
                ScrollView {
                    // "pinnedViews" is used to pin the header of each Section in LazyVStack
                    // pretty nice
                    LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                        ForEach(currentWeek) { day in
                            let date = day.date
                            let isLast = day.id == currentWeek.last?.id

                            Section {
                                // Day's content
                                VStack(alignment: .leading, spacing: 15) {
                                    TaskRow()
                                    TaskRow()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.leading, 70)
                                .padding(.top, -70)
                                .padding(.bottom, 10)
                                // Making the last section content fill the remaining space
                                // Negative padding 70 + content margin 20 + 20
                                .frame(height: isLast ? size.height - 110 : nil, alignment: .top)
                            } header: {
                                VStack(spacing: 4) {
                                    Text(date.formatted(.dateTime.weekday()))

                                    Text(date.formatted(.dateTime.day()))
                                        .font(.largeTitle.bold())
                                }
                                .frame(width: 55, height: 70)
                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .offset(y: 10)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.all, 20, for: .scrollContent)
                .scrollPosition(
                    id: Binding(get: {
                        currentWeek.first { $0.date.isSameDay(as: selectedDate) }?.id
                    }, set: { newValue in
                        selectedDate = currentWeek.first { $0.id == newValue }?.date
                    }),
                    anchor: .top
                )
                .scrollIndicators(.hidden)
                // Undoing the negative padding effect.
                // LazyVStack loads the scroll content lazily as expected. However,
                // the section content is not fully visible due to the negative padding.
                // Thus, it is not loaded until it is visible. So we need to add
                // a safe area padding to the bottom of the scroll view, and also update
                // the scroll view's bounds.
                .safeAreaPadding(.bottom, 70)
                .padding(.bottom, -70)
            }
            .background(.background)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30))
            .environment(\.colorScheme, .light)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .background(.black.opacity(0.9))
        .onAppear {
            guard selectedDate == nil else { return }

            selectedDate = currentWeek.first { $0.date.isSameDay(as: .now) }?.date
        }
    }

    @ViewBuilder
    private func headerView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.title.bold())

                Spacer(minLength: 0)

                Button {

                } label: {
                    Image(.berlinPupper)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 35, height: 35)
                        .clipShape(.circle)
                }
            }

            // Week view
            HStack(spacing: 0) {
                ForEach(currentWeek) { day in
                    let date = day.date
                    let isSameDay = date.isSameDay(as: selectedDate)


                    VStack(spacing: 6) {
                        Text(date.formatted(.dateTime.weekday()))
                            .font(.caption)

                        Text(date.formatted(.dateTime.day()))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(isSameDay ? .black : .white)
                            .frame(width: 38, height: 38)
                            .background {
                                if isSameDay {
                                    Circle()
                                        .fill(.white)
                                    // Moves the circle behind the text
                                        .matchedGeometryEffect(id: "ACTIVEDATE", in: namespace)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.25)) {
                            selectedDate = date
                        }
                    }
                }
            }
            .animation(.snappy(duration: 0.25), value: selectedDate)
            .frame(height: 80)
            .padding(.vertical, 5)
            .offset(y: 5)

            HStack {
                Text(selectedDate?.formatted(.dateTime.month(.abbreviated)) ?? "")

                Spacer()

                Text(selectedDate?.formatted(.dateTime.year()) ?? "")
            }
            .font(.caption2)
        }
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 10)
    }
}

private struct TaskRow: View {
    var isEmpty: Bool = false

    var body: some View {
        Group {
            if isEmpty {
                VStack(spacing: 8) {
                    Text("No Task Title")

                    Text("Try adding some new tasks")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 5, height: 5)

                    Text("Task Title")
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack {
                        Text("15:00 - 17:00")

                        Spacer()

                        Text("Location")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 5)
                }
                .lineLimit(1)
                .padding(15)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
                .shadow(color: .black.opacity(0.35), radius: 1)
        }
    }
}

private struct Day: Identifiable {
    let id = UUID()
    let date: Date
}

#Preview {
    TaskManagementContentView()
}
