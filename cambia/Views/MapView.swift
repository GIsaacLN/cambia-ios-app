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

    // MARK: - Body
    var body: some View {
        ZStack {
            MapViewRepresentable(
                viewModel: viewModel
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
                        // Layer Selection Button
                        Button(action: {
                            viewModel.showLayerSelection.toggle()
                        }) {
                            Image(systemName: "map")
                                .frame(width: 44, height: 44)
                                .background(Color("gray5"))
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                    }
                    .accentColor(.white)
                    .padding([.bottom, .trailing, .top], 16)
                }
                Spacer()
                // MapScaleView can be added here if needed
            }
            // Layer Selection Sheet
            if viewModel.showLayerSelection {
                LayerSelectionView(viewModel: viewModel)
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
        VStack {
            Text("Select Layers")
                .font(.headline)
                .padding()
            List {
                ForEach(viewModel.availableLayers) { layer in
                    Button(action: {
                        viewModel.toggleLayer(layer)
                    }) {
                        HStack {
                            Text(layer.name)
                            Spacer()
                            if viewModel.selectedLayers.contains(layer) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            Button(action: {
                viewModel.showLayerSelection = false
            }) {
                Text("Done")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("gray5"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .padding()
    }
}
