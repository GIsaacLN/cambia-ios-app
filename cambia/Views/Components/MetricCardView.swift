//
//  MetricCardView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 09/11/24.
//

import SwiftUI

struct MetricCardView: View {
    var title: String
    var value: String
    var icon: Image
    var color: Color = Color.gray.opacity(0.2)
    var iconColor: Color = .teal
    var footer: String?
    var isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                icon
                    .foregroundColor(iconColor)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Métrica: \(title)")

                    if isLoading {
                        ProgressView()
                            .accessibilityLabel("Cargando valor de la métrica")
                    } else {
                        Text(value)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .accessibilityValue(value)
                    }
                }
                .padding(.leading, 8)
                Spacer()
            }
            
            if let footerText = footer {
                Text(footerText)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                    .accessibilityLabel("Información adicional: \(footerText)")
            }
        }
        .padding()
        .background(color)
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Basic Metric Card
        MetricCardView(
            title: "Acceso a electricidad",
            value: "85%",
            icon: Image(systemName: "bolt.fill"),
            isLoading: true
        )
        
        // Metric Card with custom color and footer text
        MetricCardView(
            title: "Hospital más cercano",
            value: "2 km",
            icon: Image(systemName: "stethoscope"),
            color: Color.green.opacity(0.2),
            footer: "Tiempo de desplazamiento: 15 minutos\nNo. en un radio de 5 km: 1 hospital",
            isLoading: false
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
