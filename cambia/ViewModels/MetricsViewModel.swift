import SwiftUI
import MapKit
import Combine
import CoreML

class MetricsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var nearestHospitalDistance: Double = 0.0
    @Published var travelTimeToNearestHospital: Int = 0
    @Published var numberOfHospitalsInRadius: Int = 0
    
    @Published var cityArea: Double? = 0
    @Published var inundatedArea: Double? = 0
    @Published var populationVulnerability: Int? = nil
    @Published var vulnerabilityIndex: String? = nil
    @Published var floodHazardLevel: String? = nil
    @Published var threshold12h: Double? = nil
    
    @Published var floodRiskLevel: String? = nil
    @Published var hourlyPrecipitation: Double? = 50.0
    @Published var annualPrecipitation: Double? = 840.0
    @Published var floodRiskPrediction: String = "No calculado"
    @Published var inegiData: InegiData? {
        didSet { updateMetrics() }
    }

    private var cancellables = Set<AnyCancellable>()
    private var floodRiskModel: FloodRiskPredictor?
    
    // MARK: - Initialization
    init() {
        loadModel()
        updateMetrics()
    }
    
    // MARK: - Load ML Model
    private func loadModel() {
        do {
            self.floodRiskModel = try FloodRiskPredictor(configuration: MLModelConfiguration())
        } catch {
            print("Error al cargar el modelo ML: \(error)")
        }
    }
    
    // MARK: - Metrics Calculation
    func updateMetrics() {
        //TODO: - Fix Later
        resetMetrics()
    }
    
    private func resetMetrics() {
        nearestHospitalDistance = 0.0
        numberOfHospitalsInRadius = 0
        floodRiskLevel = "Not Available"
        cityArea = 0.0
        inundatedArea = 0.0
        hourlyPrecipitation = 50.0
        annualPrecipitation = 840.0
    }
    
    private func updateHospitalMetrics(userCoordinate: CLLocationCoordinate2D) {
        // TODO: - Fix Later
    }
    
    /* TODO: - Delete if not useful
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
    }*/
    
    // MARK: - Perform Prediction
    func performPrediction() {
        // Retrieve densidadPoblacional from INEGI data
        guard let inegiDensidad = inegiData?.indicators["densidad"],
              let areaInundada = inundatedArea,
              let precipitacionAnual = annualPrecipitation,
              let floodHazardLevel = floodHazardLevel else {
            floodRiskPrediction = "Datos insuficientes para la predicción"
            print("Datos insuficientes para la predicción. Current values - Densidad: \(String(describing: inegiData?.indicators["densidad"])), Área Inundada: \(String(describing: inundatedArea)), Precipitación Anual: \(String(describing: annualPrecipitation)), Nivel de Riesgo: \(String(describing: floodHazardLevel))")
            return
        }

        // Use floodHazardLevel directly as NivelRiesgo
        let nivelRiesgo: String
        switch floodHazardLevel {
        case "Muy alto", "Alto":
            nivelRiesgo = "Alto"
        case "Medio":
            nivelRiesgo = "Medio"
        default:
            nivelRiesgo = "Bajo"
        }

        do {
            let prediction = try floodRiskModel?.prediction(
                DensidadPoblacional: Int64(inegiDensidad),
                PrecipitacionAnual: Int64(precipitacionAnual),
                AreaInundada: areaInundada,
                NivelRiesgo: nivelRiesgo
            )
            
            let riskLabel = prediction?.FloodRisk == 1 ? "Alto riesgo de inundación" : "Bajo riesgo de inundación"
            
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

}
