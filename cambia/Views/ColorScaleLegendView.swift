//
//  ColorScaleLegendView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 08/11/24.
//

import SwiftUI

struct ColorScaleLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nivel de Riesgo")
                .font(.headline)
                .padding(.bottom, 4)
            HStack {
                Color.blue.frame(width: 20, height: 20)
                Text("Muy bajo")
            }
            HStack {
                Color.yellow.frame(width: 20, height: 20)
                Text("Bajo")
            }
            HStack {
                Color.orange.frame(width: 20, height: 20)
                Text("Medio")
            }
            HStack {
                Color.red.frame(width: 20, height: 20)
                Text("Alto")
            }
            HStack {
                Color.purple.frame(width: 20, height: 20)
                Text("Muy alto")
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(10)
        .padding([.leading, .bottom], 16)
    }
}

