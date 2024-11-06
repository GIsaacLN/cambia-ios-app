import SwiftUI
import MapKit
import Combine
import CoreML

class MetricsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var nearestHospitalDistance: Double = 0.0
    @Published var travelTimeToNearestHospital: Int = 0
    @Published var numberOfHospitalsInRadius: Int = 0
    @Published var floodZonePercentage: Double? = nil
    @Published var cityArea: Double? = 0 // Aquí hay que jalar los datos del inegi o poner los de la CDMX para la demo
    @Published var inundatedArea: Double? = 0 // Aquí hay que jalar los datos del inegi o poner los de la CDMX para la demo
    @Published var floodRiskLevel: String? = nil
    @Published var hourlyPrecipitation: Double? = 50.0 // Umbral de precipitación en mm o poner los de la CDMX para la demo
    @Published var annualPrecipitation: Double? = 840.0 // Promedio anual en mm o poner los de la CDMX para la demo
    @Published var floodRiskPrediction: String = "No calculado" // Resultado de la predicción
    @Published var inegiData: InegiData?
    
    // Reference to MapViewModel to access map data
    private var mapViewModel: MapViewModel
    private var cancellables = Set<AnyCancellable>()
    private var floodRiskModel: FloodRiskPredictor? // Modelo ML
    
    // MARK: - Initialization
    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel
        loadModel() // Cargar el modelo ML al inicializar

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
    
    // MARK: - Load ML Model
    private func loadModel() {
        do {
            self.floodRiskModel = try FloodRiskPredictor(configuration: MLModelConfiguration())
        } catch {
            print("Error al cargar el modelo ML: \(error)")
        }
    }

    // MARK: - Perform Prediction
    func performPrediction() {
        guard let densidadPoblacional = floodZonePercentage,
              let areaInundada = inundatedArea,
              let precipitacionAnual = annualPrecipitation else {
            floodRiskPrediction = "Datos insuficientes para la predicción"
            return
        }

        // Convertimos el nivel de riesgo a un string basado en "High" o "Low"
        let nivelRiesgo = floodRiskLevel == "High" ? "1" : "0"

        do {
            // Crear la entrada para el modelo con `NivelRiesgo` como `String`
            let prediction = try floodRiskModel?.prediction(
                DensidadPoblacional: Int64(densidadPoblacional),
                PrecipitacionAnual: Int64(precipitacionAnual),
                AreaInundada: areaInundada,
                NivelRiesgo: nivelRiesgo
            )
            
            // Asignar el resultado de la predicción basado en `FloodRisk`
            let riskLabel = prediction?.FloodRisk == 1 ? "Alto riesgo de inundación" : "Bajo riesgo de inundación"
            
            // Si deseas mostrar también la probabilidad, puedes extraerla del diccionario
            if let probability = prediction?.FloodRiskProbability[prediction?.FloodRisk ?? 0] {
                floodRiskPrediction = "\(riskLabel) (Probabilidad: \(String(format: "%.2f", probability * 100))%)"
            } else {
                floodRiskPrediction = riskLabel
            }
            
        } catch {
            floodRiskPrediction = "Error en la predicción"
            print("Error al realizar la predicción: \(error)")
        }
    }


    // MARK: - Metrics Calculation
    func updateMetrics() {
        // Reset metrics
        nearestHospitalDistance = 0.0
        numberOfHospitalsInRadius = 0
        floodZonePercentage = nil
        floodRiskLevel = nil
        cityArea = 100000.0 // Aquí hay que jalar los datos del inegi o poner los de la CDMX para la demo
        inundatedArea = 5200.0 // Aquí hay que jalar los datos del inegi o poner los de la CDMX para la demo
        hourlyPrecipitation = 50.0 // Aquí hay que jalar los datos del inegi o poner los de la CDMX para la demo
        annualPrecipitation = 840.0 // Aquí hay que jalar los datos del inegi o poner los de la CDMX para la demo

        guard let userLocation = mapViewModel.userLocation else { return }
        let userCoordinate = userLocation.coordinate
        
        // Update metrics for hospitals
        updateHospitalMetrics(userCoordinate: userCoordinate)
        
        // Update metrics for disaster risk zones
        updateRiskMetrics(fileType: floodZonesFile, metric: &floodRiskLevel, userCoordinate: userCoordinate, label: "Flood Risk")
        
        // Update metrics based on Inegi data
        updateInegiMetrics()
        
        // Perform prediction after updating metrics
        performPrediction()
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
        if let density = inegiData.indicators["densidad"] {
            floodZonePercentage = density
        }
        
        // Área de la Ciudad
        if let area = inegiData.indicators["cityArea"] {
            cityArea = area
        }
        
        // Área Inundada
        if let inundated = inegiData.indicators["inundatedArea"] {
            inundatedArea = inundated
        }
        
        // Viviendas con Agua y Electricidad
        let waterCoverage = inegiData.indicators["viviendasConAgua"]
        let electricityCoverage = inegiData.indicators["viviendasConElectricidad"]
    }
}
