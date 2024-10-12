//
//  MetricsView.swift
//  cambia
//
//  Created by yatziri on 07/10/24.
//

// Views/MetricsView.swift

import SwiftUI

struct MetricsView: View {
    @StateObject private var viewModel = MetricsViewModel()
    
    var body: some View {
        HStack {
            Grid {
                GridRow {
                    VStack {
                        Text("Escuelas")
                            .font(.title3)
                            .bold()
                        Divider()
                        HStack {
                            Text("Escuela más cercana:")
                                .font(.caption)
                            Spacer()
                            Text("2")
                                .foregroundStyle(Color.orange)
                                .font(.title)
                                .bold()
                            Text("Km")
                                .font(.caption)
                        }
                        Divider()
                        HStack {
                            Text("Tiempo de desplazamiento:")
                                .font(.caption)
                            Spacer()
                            Text("15")
                                .foregroundStyle(Color.orange)
                                .font(.title)
                                .bold()
                            Text("minutos")
                                .font(.caption)
                        }
                        Divider()
                        HStack {
                            Text("No. en un radio de")
                                .font(.caption)
                            Text("Km")
                                .font(.caption)
                            Spacer()
                            Text("5")
                                .foregroundStyle(Color.orange)
                                .font(.title)
                                .bold()
                        }
                    }
                    .padding()
                    .background(Color.gray6)
                    .cornerRadius(20)
                    .opacity(0.7)

                    Text("R1, C1")
                    Text("R1, C2")
                }
                Text("R1, C1")
                Text("R1, C2")
            }
            mapView
        }
    }

    var mapView: some View {
        MapView(
            overlays: $viewModel.overlays,
            region: $viewModel.region,
            annotations: $viewModel.annotations,
            zoomInTrigger: $viewModel.zoomInTrigger,
            zoomOutTrigger: $viewModel.zoomOutTrigger,
            showUserLocationTrigger: $viewModel.showUserLocationTrigger,
            togglePitchTrigger: $viewModel.togglePitchTrigger
        )
    }
}
