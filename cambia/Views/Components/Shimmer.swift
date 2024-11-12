//
//  Shimmer.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/11/24.
//

import SwiftUI

struct Shimmer: View {
    @State private var moveGradient = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1), Color.gray.opacity(0.3)]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .rotationEffect(.degrees(15))
        .offset(x: moveGradient ? 300 : -300)
        .onAppear {
            withAnimation(
                Animation.linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                moveGradient.toggle()
            }
        }
    }
}
