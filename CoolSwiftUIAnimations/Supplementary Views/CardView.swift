//
//  CardView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 27.06.25.
//

import SwiftUI

struct CardView: View {
    enum LayoutOrientation {
        case horizontal, vertical
    }

    var imageName: String
    var orientation: LayoutOrientation = .vertical

    private let corner = 32.0

    var body: some View {
        RoundedRectangle(cornerRadius: corner)
            .strokeBorder(.white, lineWidth: 4)
            .aspectRatio(orientation == .vertical ? 2.0 / 3.0 : 3.0 / 2.0, contentMode: .fit)
            .background {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(.rect(cornerRadius: corner))
    }
}

#Preview {
    ZStack {
        Rectangle().fill(.red.gradient)
            .ignoresSafeArea()

        VStack {
            CardView(imageName: "berlinPupper", orientation: .horizontal)
                .frame(width: 300)
                .shadow(radius: 10)
            CardView(imageName: "berlinPupper")
                .frame(width: 300)
                .shadow(radius: 10)
        }
    }
}
