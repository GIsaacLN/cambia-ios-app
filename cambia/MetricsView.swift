//
//  MetricsView.swift
//  cambia
//
//  Created by yatziri on 07/10/24.
//

import SwiftUI
import MapKit

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
        ZStack {
            MapViewRepresentable(
                overlays: $viewModel.overlays,
                region: $viewModel.region,
                searchResults: $viewModel.searchResults,
                zoomIn: $viewModel.zoomInTrigger,
                zoomOut: $viewModel.zoomOutTrigger,
                showUserLocation: $viewModel.showUserLocationTrigger,
                togglePitch: $viewModel.togglePitchTrigger
            )
            
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        // MapPitchToggle
                        Button(action: {
                            viewModel.togglePitchTrigger = true
                        }) {
                            Image(systemName: "cube")
                                .frame(width: 44, height: 44)
                                .background(Color("gray5"))
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                        // MapUserLocationButton
                        Button(action: {
                            viewModel.showUserLocationTrigger = true
                        }) {
                            Image(systemName: "location.fill")
                                .frame(width: 44, height: 44)
                                .background(Color("gray5"))
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                        // Zoom buttons
                        ZoomButtonView(zoomIn: true) {
                            viewModel.zoomInTrigger = true
                        }
                        ZoomButtonView(zoomIn: false) {
                            viewModel.zoomOutTrigger = true
                        }
                        MapButtonView {
                            viewModel.search(for: "Hospital")
                        }
                    }
                    .accentColor(.white)
                    .padding([.bottom, .trailing, .top], 16)
                }
                Spacer()
            }
        }
    }
}

struct ZoomButtonView: View {
    var zoomIn: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: zoomIn ? "plus" : "minus")
                .frame(width: 44, height: 44)
                .background(Color("gray5"))
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
        .padding(.bottom, 4)
    }
}

struct MapButtonView: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "square.stack.3d.up.fill")
                .frame(width: 44, height: 44)
                .background(Color("gray5"))
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
        .padding(.top, 4)
    }
}
