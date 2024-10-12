//
//  MetricsViewModel.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

// ViewModels/MetricsViewModel.swift

import SwiftUI
import MapKit
import Combine

class MetricsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var nearestHospitalDistance: Double = 0.0
    @Published var travelTimeToNearestHospital: Int = 0
    @Published var numberOfHospitalsInRadius: Int = 0
    @Published var floodZoneInfo: String = ""
    
    // Reference to MapViewModel to access map data
    private var mapViewModel: MapViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel
        
        // Observe changes in selected layers
        mapViewModel.$selectedLayers
            .sink { [weak self] _ in
                self?.updateMetrics()
            }
            .store(in: &cancellables)
        
        // Observe changes in annotations and overlays
        mapViewModel.$annotations
            .sink { [weak self] _ in
                self?.updateMetrics()
            }
            .store(in: &cancellables)
        
        mapViewModel.$overlays
            .sink { [weak self] _ in
                self?.updateMetrics()
            }
            .store(in: &cancellables)
        
        // Observe changes in user location
        mapViewModel.$userLocation
            .sink { [weak self] _ in
                self?.updateMetrics()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Metrics Calculation
    func updateMetrics() {
        // Reset metrics
        nearestHospitalDistance = 0.0
        numberOfHospitalsInRadius = 0
        floodZoneInfo = ""
        
        guard let userLocation = mapViewModel.userLocation else { return }
        let userCoordinate = userLocation.coordinate
        
        // Hospitals Layer Metrics
        if let hospitalLayer = mapViewModel.availableLayers.first(where: { $0.name == "Hospitals" }),
           mapViewModel.selectedLayers.contains(hospitalLayer),
           let hospitalAnnotations = mapViewModel.layerAnnotations[hospitalLayer.id] {
            
            numberOfHospitalsInRadius = hospitalAnnotations.count
            
            // Calculate nearest hospital distance
            var minDistance: CLLocationDistance = Double.greatestFiniteMagnitude
            for annotation in hospitalAnnotations {
                let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                let distance = userLocation.distance(from: annotationLocation)
                if distance < minDistance {
                    minDistance = distance
                }
            }
            nearestHospitalDistance = minDistance / 1000.0 // Convert to kilometers
        }
        
        // Flood Zones Layer Metrics
        if let floodLayer = mapViewModel.availableLayers.first(where: { $0.name == "Flood Zones" }),
           mapViewModel.selectedLayers.contains(floodLayer),
           let floodOverlays = mapViewModel.layerOverlays[floodLayer.id] {
            
            let mapPoint = MKMapPoint(userCoordinate)
            var isInFloodZone = false
            for overlay in floodOverlays {
                if let polygon = overlay as? MKPolygon {
                    if polygon.contains(coordinate: userCoordinate) {
                        isInFloodZone = true
                        break
                    }
                }
            }
            floodZoneInfo = isInFloodZone ? "You are in a flood zone" : "You are not in a flood zone"
        }
    }

    
}
