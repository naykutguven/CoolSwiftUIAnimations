//
//  CardView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 27.06.25.
//

import SwiftUI

struct CardView: View {
    var imageName: String
    private let corner = 32.0

    var body: some View {
        RoundedRectangle(cornerRadius: corner)
            .fill(.clear)
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .background {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(.rect(cornerRadius: corner))
            .shadow(radius: 16)
            .overlay {
                RoundedRectangle(cornerRadius: corner)
                    .strokeBorder(.white, lineWidth: 4)
            }
    }
}

#Preview {
    ZStack {
        Rectangle().fill(.red.gradient)
            .ignoresSafeArea()

        CardView(imageName: "berlinPupper")
            .frame(width: 300)
    }
}
