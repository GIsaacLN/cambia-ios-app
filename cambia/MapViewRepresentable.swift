//
//  MapViewRepresentable.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var overlays: [StyledPolygon]
    @Binding var region: MKCoordinateRegion
    @Binding var annotations: [MKAnnotation]
    
    @Binding var zoomIn: Bool
    @Binding var zoomOut: Bool
    @Binding var showUserLocation: Bool
    @Binding var togglePitch: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView
        
        mapView.setRegion(region, animated: false)
        mapView.addOverlays(overlays)
        mapView.addAnnotations(annotations)
        
        // Enable user location
        mapView.showsUserLocation = true
        
        // Enable interaction modes
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update overlays
        if mapView.overlays.count != overlays.count {
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlays(overlays)
        }
        
        // Update region
        if mapView.region.center.latitude != region.center.latitude ||
            mapView.region.center.longitude != region.center.longitude ||
            mapView.region.span.latitudeDelta != region.span.latitudeDelta ||
            mapView.region.span.longitudeDelta != region.span.longitudeDelta {
            mapView.setRegion(region, animated: true)
        }
        
        // Update annotations
        if mapView.annotations.count != annotations.count {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(annotations)
        }
        
        // Handle zoom in
        if zoomIn {
            var newRegion = mapView.region
            newRegion.span.latitudeDelta /= 2.0
            newRegion.span.longitudeDelta /= 2.0
            mapView.setRegion(newRegion, animated: true)
            DispatchQueue.main.async {
                self.zoomIn = false
            }
        }
        
        // Handle zoom out
        if zoomOut {
            var newRegion = mapView.region
            newRegion.span.latitudeDelta *= 2.0
            newRegion.span.longitudeDelta *= 2.0
            mapView.setRegion(newRegion, animated: true)
            DispatchQueue.main.async {
                self.zoomOut = false
            }
        }
        
        // Handle pitch toggle
        if togglePitch {
            let camera = mapView.camera
            camera.pitch = camera.pitch == 0 ? 60 : 0
            mapView.setCamera(camera, animated: true)
            DispatchQueue.main.async {
                self.togglePitch = false
            }
        }
        
        // Handle user location
        if showUserLocation {
            mapView.setUserTrackingMode(.follow, animated: true)
            DispatchQueue.main.async {
                self.showUserLocation = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        weak var mapView: MKMapView?

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        // Customize overlay rendering
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? StyledPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = polygon.fillColor
                renderer.strokeColor = polygon.strokeColor
                renderer.lineWidth = polygon.lineWidth
                return renderer
            }
            // Handle other overlay types if needed
            return MKOverlayRenderer(overlay: overlay)
        }
        
        // Handle region changes
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.region = mapView.region
            }
        }
    }
}
