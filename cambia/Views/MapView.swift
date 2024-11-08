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
    @ObservedObject var viewModel: MapViewModel
    
    @EnvironmentObject var municipalidadModel: CiudadMunicipioViewModel

    // MARK: - Body
    var body: some View {
        ZStack {
            MapViewRepresentable(
                viewModel: viewModel
            )
//            .frame(width: 560,height: 690)
            VStack {
                HStack {
                    Spacer()
                    VStack (alignment:.trailing){
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
                            viewModel.recenter(to: municipalidadModel.selectedCiudadMunicipio.municipios ?? .alvaroObregon)
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
                        Spacer()
                    }
                    .padding([.leading, .bottom], 16)
                }
            }
            /*.overlay {
                if viewModel.showLayerSelection {
                    LayerSelectionView(viewModel: viewModel)
                        
                }
            }*/
            // Layer Selection Sheet
            
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
    MapView(viewModel: MapViewModel.init())
}
