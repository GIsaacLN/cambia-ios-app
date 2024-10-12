//
//  MapView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    // MARK: - Bindings
    @Binding var overlays: [StyledPolygon]
    @Binding var region: MKCoordinateRegion
    @Binding var annotations: [MKAnnotation]
    
    // Action triggers
    @Binding var zoomInTrigger: Bool
    @Binding var zoomOutTrigger: Bool
    @Binding var showUserLocationTrigger: Bool
    @Binding var togglePitchTrigger: Bool
    
    // MARK: - Body
    var body: some View {
        ZStack {
            MapViewRepresentable(
                overlays: $overlays,
                region: $region,
                annotations: $annotations,
                zoomIn: $zoomInTrigger,
                zoomOut: $zoomOutTrigger,
                showUserLocation: $showUserLocationTrigger,
                togglePitch: $togglePitchTrigger
            )
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        // MapPitchToggle
                        Button(action: {
                            togglePitchTrigger = true
                        }) {
                            Image(systemName: "cube")
                                .frame(width: 44, height: 44)
                                .background(Color("gray5"))
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                        // MapUserLocationButton
                        Button(action: {
                            showUserLocationTrigger = true
                        }) {
                            Image(systemName: "location.fill")
                                .frame(width: 44, height: 44)
                                .background(Color("gray5"))
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                        // Zoom buttons
                        ZoomButtonView(zoomIn: true) {
                            zoomInTrigger = true
                        }
                        ZoomButtonView(zoomIn: false) {
                            zoomOutTrigger = true
                        }
                        // Additional buttons can be added here
                    }
                    .accentColor(.white)
                    .padding([.bottom, .trailing, .top], 16)
                }
                Spacer()
                // MapScaleView can be added here if needed
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
