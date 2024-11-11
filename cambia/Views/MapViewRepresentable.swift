//
//  MapViewRepresentable.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView
        
        mapView.setRegion(viewModel.region, animated: false)
        mapView.addOverlays(viewModel.overlays)
        mapView.addAnnotations(viewModel.annotations)
        
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
        // Actualización de overlays
        let currentOverlays = Set(mapView.overlays.compactMap { $0 as? StyledPolygon })
        let newOverlays = Set(viewModel.overlays.compactMap { $0 as? StyledPolygon })

        if currentOverlays != newOverlays {
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlays(viewModel.overlays)
        }

        // Actualización de la región
        if mapView.region.center.latitude != viewModel.region.center.latitude ||
            mapView.region.center.longitude != viewModel.region.center.longitude ||
            mapView.region.span.latitudeDelta != viewModel.region.span.latitudeDelta ||
            mapView.region.span.longitudeDelta != viewModel.region.span.longitudeDelta {
            mapView.setRegion(viewModel.region, animated: true)
        }

        // Actualización de anotaciones
        let currentAnnotations = Set(mapView.annotations.compactMap { $0 as? MKPointAnnotation })
        let newAnnotations = Set(viewModel.annotations.compactMap { $0 as? MKPointAnnotation })

        if currentAnnotations != newAnnotations {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(viewModel.annotations)
        }

        // Manejo de zoom in
        if viewModel.zoomInTrigger {
            var newRegion = mapView.region
            newRegion.span.latitudeDelta /= 2.0
            newRegion.span.longitudeDelta /= 2.0
            mapView.setRegion(newRegion, animated: true)
            DispatchQueue.main.async {
                self.viewModel.zoomInTrigger = false
            }
        }

        // Manejo de zoom out
        if viewModel.zoomOutTrigger {
            var newRegion = mapView.region
            newRegion.span.latitudeDelta *= 2.0
            newRegion.span.longitudeDelta *= 2.0
            mapView.setRegion(newRegion, animated: true)
            DispatchQueue.main.async {
                self.viewModel.zoomOutTrigger = false
            }
        }

        // Manejo de alternancia de inclinación
        if viewModel.togglePitchTrigger {
            let camera = mapView.camera
            camera.pitch = camera.pitch == 0 ? 60 : 0
            mapView.setCamera(camera, animated: true)
            DispatchQueue.main.async {
                self.viewModel.togglePitchTrigger = false
            }
        }

        // Seguimiento de la ubicación del usuario
        if viewModel.showUserLocationTrigger {
            mapView.setUserTrackingMode(.follow, animated: true)
            DispatchQueue.main.async {
                self.viewModel.showUserLocationTrigger = false
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
            } else if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.white
                renderer.lineWidth = 1.0
                return renderer
            } else {
                print("Unhandled overlay type: \(type(of: overlay))")
                return MKOverlayRenderer(overlay: overlay)
            }
        }

        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            if let location = userLocation.location {
                DispatchQueue.main.async {
                    self.parent.viewModel.userLocation = location
                }
            }
        }

        // Customize annotation view for points of interest
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let subtitle = annotation.subtitle as? String else { return nil }

            // Define a reusable identifier for the annotation view
            let identifier = "CustomAnnotationView"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true  // Enable callouts for titles
            } else {
                annotationView?.annotation = annotation
            }

            // Configure the background color and icon based on annotation type with softer colors
            var backgroundColor: UIColor
            var symbolName: String
            
            switch subtitle {
            case "Hospital":
                backgroundColor = UIColor.systemRed
                symbolName = "cross.fill"
            case "Police":
                backgroundColor = UIColor.systemBlue
                symbolName = "shield.fill"
            case "Fire Station":
                backgroundColor = UIColor.systemOrange
                symbolName = "flame.fill"
            default:
                backgroundColor = UIColor.systemGray
                symbolName = "mappin.circle.fill"
            }
            
            // Create a rounded rectangular background for the icon
            let backgroundSize = CGSize(width: 35, height: 35)
            let symbolSize: CGFloat = 20

            let backgroundView = UIView(frame: CGRect(origin: .zero, size: backgroundSize))
            backgroundView.backgroundColor = backgroundColor
            backgroundView.layer.cornerRadius = backgroundSize.height / 2  // Makes it rounded
            backgroundView.clipsToBounds = false  // Allows shadow to show outside of bounds

            // Add a subtle shadow
            backgroundView.layer.shadowColor = UIColor.black.cgColor
            backgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
            backgroundView.layer.shadowOpacity = 0.3
            backgroundView.layer.shadowRadius = 3

            // Center the SF Symbol within the background
            let symbolImage = UIImageView(image: UIImage(systemName: symbolName))
            symbolImage.tintColor = .white
            symbolImage.frame = CGRect(x: (backgroundSize.width - symbolSize) / 2, y: (backgroundSize.height - symbolSize) / 2, width: symbolSize, height: symbolSize)
            backgroundView.addSubview(symbolImage)

            // Render the background view with the icon and shadow as an image for the annotation view
            UIGraphicsBeginImageContextWithOptions(backgroundView.bounds.size, false, 0.0)
            backgroundView.layer.render(in: UIGraphicsGetCurrentContext()!)
            annotationView?.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return annotationView
        }

        // Handle region changes
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.parent.viewModel.region = mapView.region
            }
        }
    }
}
