// MetricsViewModel.swift
// cambia

import SwiftUI
import MapKit
import Combine

class MetricsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var nearestHospitalDistance: Double = 0.0
    @Published var travelTimeToNearestHospital: Int = 0
    @Published var numberOfHospitalsInRadius: Int = 0
    @Published var floodZonePercentage: Double? = nil
    @Published var cityArea: Double? = 100000.0 // Área de ejemplo de la ciudad en Km²
    @Published var inundatedArea: Double? = 5200.0 // Área inundada de ejemplo en Km²
    @Published var floodRiskLevel: String? = nil
    @Published var hourlyPrecipitation: Double? = 50.0 // Umbral de precipitación en mm
    @Published var annualPrecipitation: Double? = 840.0 // Promedio anual en mm
    @Published var inegiData: InegiData?
    
    // Reference to MapViewModel to access map data
    private var mapViewModel: MapViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel

        // Observe changes in selected layers and map data
        mapViewModel.$selectedLayers
            .sink { [weak self] _ in self?.updateMetrics() }
            .store(in: &cancellables)

        mapViewModel.$annotations
            .sink { [weak self] _ in self?.updateMetrics() }
            .store(in: &cancellables)

        mapViewModel.$overlays
            .sink { [weak self] _ in self?.updateMetrics() }
            .store(in: &cancellables)
        
        mapViewModel.$userLocation
            .sink { [weak self] _ in self?.updateMetrics() }
            .store(in: &cancellables)
    }

    // MARK: - Metrics Calculation
    func updateMetrics() {
        // Reset metrics
        nearestHospitalDistance = 0.0
        numberOfHospitalsInRadius = 0
        floodZonePercentage = nil
        floodRiskLevel = nil
        cityArea = 100000.0 // Default city area, adjust based on data if available
        inundatedArea = 5200.0 // Default flooded area
        hourlyPrecipitation = 50.0 // Default threshold precipitation
        annualPrecipitation = 840.0 // Default average annual precipitation

        guard let userLocation = mapViewModel.userLocation else { return }
        let userCoordinate = userLocation.coordinate
        
        // Update metrics for hospitals
        updateHospitalMetrics(userCoordinate: userCoordinate)
        
        // Update metrics for disaster risk zones
        updateRiskMetrics(fileType: floodZonesFile, metric: &floodRiskLevel, userCoordinate: userCoordinate, label: "Flood Risk")
        
        // Update metrics based on Inegi data
        updateInegiMetrics()
    }
    
    private func updateHospitalMetrics(userCoordinate: CLLocationCoordinate2D) {
        if let hospitalLayer = mapViewModel.availableLayers.first(where: { $0.name == "Hospitals" }),
           mapViewModel.selectedLayers.contains(hospitalLayer),
           let hospitalAnnotations = mapViewModel.layerAnnotations[hospitalLayer.id] {

            numberOfHospitalsInRadius = hospitalAnnotations.count

            // Calculate nearest hospital distance
            var minDistance: CLLocationDistance = Double.greatestFiniteMagnitude
            for annotation in hospitalAnnotations {
                let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                let distance = mapViewModel.userLocation?.distance(from: annotationLocation) ?? 0
                if distance < minDistance {
                    minDistance = distance
                }
            }
            nearestHospitalDistance = minDistance / 1000.0 // Convert to kilometers
        }
    }

    private func updateRiskMetrics(fileType: String, metric: inout String?, userCoordinate: CLLocationCoordinate2D, label: String) {
        if let overlayLayer = mapViewModel.availableLayers.first(where: { $0.type == .geoJSON(fileType) }),
           mapViewModel.selectedLayers.contains(overlayLayer),
           let overlays = mapViewModel.layerOverlays[overlayLayer.id] {

            let mapPoint = MKMapPoint(userCoordinate)
            var isInRiskZone = false

            for overlay in overlays {
                if let polygon = overlay as? MKPolygon, polygon.contains(coordinate: userCoordinate) {
                    isInRiskZone = true
                    break
                }
            }

            metric = isInRiskZone ? "\(label): High" : "\(label): Low"
        } else {
            metric = "\(label): Not Available"
        }
    }

    private func updateInegiMetrics() {
        guard let inegiData = inegiData else { return }
        
        // Densidad Poblacional
        if let density = inegiData.indicators["dencidad"] {
            floodZonePercentage = density
        }
        
        // Área de la Ciudad (Usa un valor predeterminado o ajusta si el dato exacto está disponible)
        if let area = inegiData.indicators["cityArea"] {
            cityArea = area
        }
        
        // Área Inundada
        if let inundated = inegiData.indicators["inundatedArea"] {
            inundatedArea = inundated
        }
        
        // Población Total
        if let totalPopulation = inegiData.indicators["poblacionTotal"] {
            // Actualiza algún cálculo relacionado si es necesario, como el riesgo basado en densidad
        }
        
        // Viviendas con Agua y Electricidad
        let waterCoverage = inegiData.indicators["viviendasConAgua"]
        let electricityCoverage = inegiData.indicators["viviendasConElectricidad"]

        // Update values in other views if necessary
        // Example: Some metric based on water/electricity coverage or area inundation, etc.
    }
}
