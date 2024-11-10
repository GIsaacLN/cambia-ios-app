import SwiftUI
import MapKit
import Combine
import CoreML
import CoreLocation

class MetricsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var totalHospitalsInMunicipio: Int = 0
    @Published var averageHospitalDistance: Double = 0.0
    @Published var totalPoliceStationsInMunicipio: Int = 0
    @Published var averagePoliceStationDistance: Double = 0.0
    @Published var totalFireStationsInMunicipio: Int = 0
    @Published var averageFireStationDistance: Double = 0.0

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
        floodRiskLevel = "Not Available"
        cityArea = 0.0
        inundatedArea = 0.0
        hourlyPrecipitation = 50.0
        annualPrecipitation = 840.0
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

    // Check if a given point is inside a polygon
    func pointInPolygon(point: CLLocationCoordinate2D, polygon: [[Double]]) -> Bool {
        var inside = false
        let count = polygon.count
        
        var j = count - 1
        for i in 0..<count {
            let xi = polygon[i][0], yi = polygon[i][1]
            let xj = polygon[j][0], yj = polygon[j][1]
            
            let intersect = ((yi > point.latitude) != (yj > point.latitude)) &&
                            (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi)
            if intersect {
                inside = !inside
            }
            j = i
        }
        
        return inside
    }

    func updateMetricsForMunicipio(municipio: Municipio) {
        guard let geometry = municipio.geometry,
              let centroid = calculateCentroid(of: geometry) else {
            print("Unable to calculate centroid for municipio: \(municipio.displayFullName)")
            return
        }

        let regionRadius = municipio.cityArea.map { sqrt($0) * 1000 } ?? 50000 // Estimate radius from area, or default to 50km if unavailable
        let newRegion = MKCoordinateRegion(center: centroid, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

        // Perform search for each type with municipio geometry filter
        searchForPOI(type: "Hospital", centroid: centroid, region: newRegion, geometry: geometry) { count, avgDistance in
            DispatchQueue.main.async {
                self.totalHospitalsInMunicipio = count
                self.averageHospitalDistance = avgDistance
            }
        }
        
        searchForPOI(type: "Police", centroid: centroid, region: newRegion, geometry: geometry) { count, avgDistance in
            DispatchQueue.main.async {
                self.totalPoliceStationsInMunicipio = count
                self.averagePoliceStationDistance = avgDistance
            }
        }
        
        searchForPOI(type: "Fire Station", centroid: centroid, region: newRegion, geometry: geometry) { count, avgDistance in
            DispatchQueue.main.async {
                self.totalFireStationsInMunicipio = count
                self.averageFireStationDistance = avgDistance
            }
        }
    }

    private func searchForPOI(type: String, centroid: CLLocationCoordinate2D, region: MKCoordinateRegion, geometry: Geometry, completion: @escaping (Int, Double) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = type
        request.resultTypes = .pointOfInterest
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Error searching for \(type): \(error.localizedDescription)")
                completion(0, 0.0)
                return
            }

            guard let response = response else {
                print("No response received for \(type)")
                completion(0, 0.0)
                return
            }

            // Filter items based on whether they are within the municipio geometry
            let filteredItems = response.mapItems.filter { item in
                let coordinate = item.placemark.coordinate
                
                if case let .polygon(coordinatesArray) = geometry.coordinates, let firstRing = coordinatesArray.first {
                    return self.pointInPolygon(point: coordinate, polygon: firstRing)
                }
                return false
            }

            let totalItems = filteredItems.count

            let totalDistance = filteredItems.reduce(0.0) { sum, item in
                let location = CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                let centro = CLLocation(latitude: centroid.latitude, longitude: centroid.longitude)
                let distance = location.distance(from: centro) // in meters

                return sum + distance
            }

            let averageDistance = totalItems > 0 ? totalDistance / Double(totalItems) / 1000.0 : 0.0
            completion(totalItems, averageDistance)
        }
    }

    func calculateCentroid(of geometry: Geometry) -> CLLocationCoordinate2D? {
        switch geometry.coordinates {
        case .polygon(let coordinatesArray):
            // Use the first ring (outer boundary) for centroid calculation
            guard let firstRing = coordinatesArray.first else { return nil }
            var sumLatitude: Double = 0
            var sumLongitude: Double = 0
            let totalPoints = Double(firstRing.count)
            
            for coordinate in firstRing {
                if coordinate.count >= 2 {
                    let longitude = coordinate[0]
                    let latitude = coordinate[1]
                    sumLatitude += latitude
                    sumLongitude += longitude
                }
            }
            
            if totalPoints > 0 {
                let centroidLatitude = sumLatitude / totalPoints
                let centroidLongitude = sumLongitude / totalPoints
                return CLLocationCoordinate2D(latitude: centroidLatitude, longitude: centroidLongitude)
            }
        case .point(let point):
            if point.count >= 2 {
                let longitude = point[0]
                let latitude = point[1]
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        case .invalid:
            return nil
        }
        return nil
    }

}
