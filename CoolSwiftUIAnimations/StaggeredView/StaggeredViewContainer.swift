//
//  StaggeredViewContainer.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 27.06.25.
//

import SwiftUI

struct StaggeredViewContainer: View {
    @State private var showContent = false
    var body: some View {
        ScrollView {
            VStack {
                Button("Tap to Hide/Reveal") {
                    showContent.toggle()
                }
                .buttonStyle(.borderedProminent)

                StaggeredView {
                    if showContent {
                        ForEach(ItemModel.dogSamples) { item in
                            NotificationView(
                                imageName: item.imageName,
                                title: item.title,
                                subtitle: item.description
                            )
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.orange.gradient)
    }
}

#Preview {
    StaggeredViewContainer()
}
