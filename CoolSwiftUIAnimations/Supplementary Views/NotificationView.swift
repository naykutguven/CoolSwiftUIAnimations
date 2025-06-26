//
//  NotificationView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 26.06.25.
//

import SwiftUI

struct NotificationView: View {
    var imageName: String
    var title: String
    var subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout)
                    .bold()

                Text(subtitle)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }
}

#Preview {
    ZStack {
        Image(.ancientTree)
            .resizable()
            .ignoresSafeArea()
        NotificationView(
            imageName: "berlinPupper",
            title: "Notification",
            subtitle: "Notification summary"
        )
        .padding()
        .frame(height: 50)
    }
}
