//
//  CardView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 27.06.25.
//

import SwiftUI

struct CardView: View {
    var imageName: String
    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 300)
                .clipShape(.rect(cornerRadius: 32))
                .overlay {
                    RoundedRectangle(cornerRadius: 32)
                        .strokeBorder(.white, lineWidth: 4)
                }
                .shadow(radius: 12)
        }
    }
}

#Preview {
    ZStack {
        Rectangle().fill(.red.gradient)
            .ignoresSafeArea()
        CardView(imageName: "berlinPupper")
            .frame(width: 200, height: 300)
    }
}
