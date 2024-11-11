//
//  MapView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

// Views/MapView.swift

import SwiftUI
import MapKit

struct MapView: View {
    // MARK: - Observed Object
    @EnvironmentObject var viewModel: MapViewModel
    @EnvironmentObject var settings: SelectedMunicipio

    // MARK: - Body
    var body: some View {
        ZStack {
            MapViewRepresentable(
                viewModel: viewModel
            )
            VStack {
                HStack {
                    Spacer()
                    VStack (alignment:.trailing){
                        // Botón para cambiar vista del mapa
                        Button(action: {
                            viewModel.togglePitchTrigger = true
                        }) {
                            Image(systemName: "cube")
                                .frame(width: 44, height: 44)
                                .background(Color("gray5"))
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                        .accessibilityLabel("Cambiar ángulo del mapa")
                        .accessibilityHint("Toca para cambiar la vista del mapa")
                        
                        // Botón para centrar mapa
                        Button(action: {
                            if let municipio = settings.selectedMunicipio {
                                viewModel.recenter(to: municipio)
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .frame(width: 44, height: 44)
                                .background(Color("gray5"))
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                        .accessibilityLabel("Centrar mapa")
                        .accessibilityHint("Centrar el mapa en el municipio seleccionado")

                        // Botón para acercar
                        ZoomButtonView(zoomIn: true) {
                            viewModel.zoomInTrigger = true
                        }
                        .accessibilityHidden(true) // Opcional si no es necesario para usuarios de VoiceOver

                        // Botón para alejar
                        ZoomButtonView(zoomIn: false) {
                            viewModel.zoomOutTrigger = true
                        }
                        .accessibilityHidden(true) // Opcional si no es necesario para usuarios de VoiceOver

                        // Layer Selection Button
                        Button(action: {
                            viewModel.showLayerSelection.toggle()
                        }) {
                            Image(systemName: "map")
                                .frame(width: 44, height: 44)
                                .background(Color("gray5"))
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .opacity(viewModel.showLayerSelection ? 0.7  : 1)
                        }
                        .accessibilityHidden(true) // Opcional si no es necesario para usuarios de VoiceOver

                        if viewModel.showLayerSelection {
                            LayerSelectionView(viewModel: viewModel)
                                .cornerRadius(10)
                                .frame(width: 300)
                        }
                    }
                    .accentColor(.white)
                    .padding([.bottom, .trailing, .top], 16)
                }
                Spacer()

                if viewModel.isFloodLayerSelected {
                    HStack {
                        ColorScaleLegendView()
                            .accessibilityHidden(true)
                        Spacer()
                    }
                    .padding([.leading, .bottom], 16)
                }
            }
            .preferredColorScheme(.dark)
        }
        .onChange(of: settings.selectedMunicipio?.clave) {
            if let municipio = settings.selectedMunicipio {
                viewModel.updateLayersForMunicipio(municipio)
                viewModel.selectedMunicipio = municipio
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

struct LayerSelectionView: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
            List {
                ForEach(viewModel.availableLayers) { layer in
                    Button(action: {
                        viewModel.toggleLayer(layer)
                    }) {
                        HStack {
                            if viewModel.selectedLayers.contains(layer) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.cyan)
                                    .padding(.trailing)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.white)
                                    .padding(.trailing)
                            }
                            
                            Text(layer.name)
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color("gray5"))
            }
            .listStyle(.plain)
            .cornerRadius(20)
            .scrollDisabled(true)
    }
}

#Preview{
    MapView()
        .environmentObject(MapViewModel())
        .environmentObject(SelectedMunicipio())
}
