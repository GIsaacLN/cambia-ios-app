//
//  MapViewModel.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

import SwiftUI
import MapKit

// Agregar los nombres de los archivos JSON
let floodZonesFile = "inundacionmunicipio"
let landslideZonesFile = "laderas"
let tsunamiZonesFile = "tsunamis"
let volcanoZonesFile = "volcanesactivos"

class MapViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var overlays: [MKOverlay] = []
    @Published var annotations: [MKAnnotation] = []
    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocation?

    // Action triggers
    @Published var zoomInTrigger: Bool = false
    @Published var zoomOutTrigger: Bool = false
    @Published var showUserLocationTrigger: Bool = false
    @Published var togglePitchTrigger: Bool = false

    // Layer management
    @Published var selectedLayers: [MapLayer] = []
    @Published var availableLayers: [MapLayer] = []
    @Published var showLayerSelection: Bool = false
    
    var isFloodLayerSelected: Bool {
        selectedLayers.contains { $0.name == "Riesgo de Inundaciones" }
    }
    
    // Dictionaries to associate overlays and annotations with layers
    var layerOverlays: [UUID: [MKOverlay]] = [:]
    var layerAnnotations: [UUID: [MKAnnotation]] = [:]
    
    
    // MARK: - Initialization
    init() {
        // Initialize the default region (Ciudad de México)
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        // Initialize available layers
        setupAvailableLayers()
    }
    
    // MARK: - Layer Setup
    func setupAvailableLayers() {
        availableLayers = [
            MapLayer(name: "Riesgo de Inundaciones", type: .geoJSON(floodZonesFile)),
            MapLayer(name: "Zonas de Deslizamiento de Tierra", type: .geoJSON(landslideZonesFile)),
            MapLayer(name: "Riesgo de Tsunami", type: .geoJSON(tsunamiZonesFile)),
            MapLayer(name: "Volcanes Activos", type: .geoJSON(volcanoZonesFile)),
            MapLayer(name: "Hospitales", type: .pointsOfInterest("Hospital")),
            MapLayer(name: "Estaciones de Policía", type: .pointsOfInterest("Police")),
            MapLayer(name: "Estaciones de Bomberos", type: .pointsOfInterest("Fire Station"))
        ]
    }

    // MARK: - Layer Selection
    func toggleLayer(_ layer: MapLayer) {
        if selectedLayers.contains(layer) {
            selectedLayers.removeAll { $0 == layer }
            removeLayer(layer)
        } else {
            selectedLayers.append(layer)
            addLayer(layer)
        }
    }
    
    // Modify addLayer and removeLayer methods
    private func addLayer(_ layer: MapLayer) {
        switch layer.type {
        case .geoJSON(let fileName):
            let newOverlays = loadGeoJSONOverlay(fileName: fileName)
            layerOverlays[layer.id] = newOverlays
            overlays.append(contentsOf: newOverlays)
        case .pointsOfInterest(let query):
            search(for: query) { newAnnotations in
                self.layerAnnotations[layer.id] = newAnnotations
                DispatchQueue.main.async {
                    self.annotations.append(contentsOf: newAnnotations)
                }
            }
        }
    }
    
    private func removeLayer(_ layer: MapLayer) {
        if let overlaysToRemove = layerOverlays[layer.id] {
            overlays.removeAll { overlay in
                overlaysToRemove.contains(where: { $0 === overlay })
            }
            layerOverlays[layer.id] = nil
        }
        if let annotationsToRemove = layerAnnotations[layer.id] {
            annotations.removeAll { annotation in
                annotationsToRemove.contains(where: { $0 === annotation })
            }
            layerAnnotations[layer.id] = nil
        }
    }

    // MARK: - Overlay Loading
    private func loadGeoJSONOverlay(fileName: String) -> [MKOverlay] {
        var newOverlays: [MKOverlay] = []

        guard let jsonUrl = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("GeoJSON file '\(fileName)' not found")
            return newOverlays
        }

        do {
            let jsonData = try Data(contentsOf: jsonUrl)
            let decoder = MKGeoJSONDecoder()
            let geoJSONObjects = try decoder.decode(jsonData)
            newOverlays = parseGeoJSON(geoJSONObjects, fileName: fileName)
        } catch {
            print("Error loading GeoJSON: \(error)")
        }

        return newOverlays
    }

    private func parseGeoJSON(_ geoJSONObjects: [MKGeoJSONObject], fileName: String) -> [MKOverlay] {
        var overlays: [MKOverlay] = []

        for object in geoJSONObjects {
            if let feature = object as? MKGeoJSONFeature {

                var fillColor: UIColor = .red.withAlphaComponent(0.5)
                var strokeColor: UIColor = .white
                let lineWidth: CGFloat = 1.0

                // Personalización de colores según el tipo de capa
                switch fileName {
                case floodZonesFile:
                    if let propertiesData = feature.properties,
                       let properties = try? JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any] {
                        if let dangerLevel = properties["PELIGRO_IN"] as? String {
                            switch dangerLevel {
                                case "Muy bajo":
                                    fillColor = UIColor.systemBlue.withAlphaComponent(0.6)
                                case "Bajo":
                                    fillColor = UIColor.systemYellow.withAlphaComponent(0.6)
                                case "Medio":
                                    fillColor = UIColor.systemOrange.withAlphaComponent(0.6)
                                case "Alto":
                                    fillColor = UIColor.systemRed.withAlphaComponent(0.6)
                                case "Muy alto":
                                    fillColor = UIColor.purple.withAlphaComponent(0.6)
                                default:
                                    fillColor = UIColor.gray.withAlphaComponent(0.6)
                            }
                        }
                    }
                case landslideZonesFile:
                    fillColor = .brown.withAlphaComponent(0.6)
                    strokeColor = .brown
                case tsunamiZonesFile:
                    fillColor = .cyan.withAlphaComponent(0.6)
                    strokeColor = .cyan
                case volcanoZonesFile:
                    fillColor = .red.withAlphaComponent(0.6)
                    strokeColor = .darkGray
                default:
                    break
                }

                for geometry in feature.geometry {
                    if let polygon = geometry as? MKPolygon {
                        let styledPolygon = StyledPolygon(points: polygon.points(), count: polygon.pointCount)
                        styledPolygon.fillColor = fillColor
                        styledPolygon.strokeColor = strokeColor
                        styledPolygon.lineWidth = lineWidth
                        overlays.append(styledPolygon)
                    } else if let point = geometry as? MKPointAnnotation {
                        // Agrega el punto a las anotaciones en lugar de los overlays
                        DispatchQueue.main.async {
                            self.annotations.append(point)
                        }
                    } else if let multiPolygon = geometry as? MKMultiPolygon {
                        for subPolygon in multiPolygon.polygons {
                            let styledPolygon = StyledPolygon(points: subPolygon.points(), count: subPolygon.pointCount)
                            styledPolygon.fillColor = fillColor
                            styledPolygon.strokeColor = strokeColor
                            styledPolygon.lineWidth = lineWidth
                            overlays.append(styledPolygon)
                        }
                    }
                }
            }
        }
        return overlays
    }


    // MARK: - Search Functionality
    private func search(for query: String, completion: @escaping ([MKAnnotation]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                completion([])
                return
            }

            if let response = response {
                let newAnnotations = response.mapItems.map { item in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    return annotation
                }
                completion(newAnnotations)
            } else {
                completion([])
            }
        }
    }
    
    func displayMunicipioGeometry(_ municipio: Municipio) {
        guard let geometry = municipio.geometry else {
            print("No geometry found for municipio: \(municipio.displayFullName)")
            return
        }

        var newOverlays: [MKOverlay] = []

        // Add color and styling based on municipio type
        let fillColor: UIColor = .gray.withAlphaComponent(0.3)
        let strokeColor: UIColor = .white
        let lineWidth: CGFloat = 1.0

        // Convert 'geometry' to MKPolygon or MKMultiPolygon
        if let overlay = convertGeometryToOverlay(geometry) {
            if let styledPolygon = overlay as? MKPolygon {
                let styledPolygon = StyledPolygon(points: styledPolygon.points(), count: styledPolygon.pointCount)
                styledPolygon.fillColor = fillColor
                styledPolygon.strokeColor = strokeColor
                styledPolygon.lineWidth = lineWidth
                newOverlays.append(styledPolygon)
            }
        } else {
            print("Unable to convert geometry to overlay for municipio: \(municipio.displayFullName)")
        }

        // Clear previous overlays and add the new overlays
        DispatchQueue.main.async {
            self.overlays.removeAll()  // Clear previous overlays
            self.overlays.append(contentsOf: newOverlays)
        }
    }

    private func convertGeometryToOverlay(_ geometry: Geometry) -> MKOverlay? {
        switch geometry.coordinates {
        case .polygon(let coordinatesArray):
            // coordinatesArray is [[[Double]]] - array of rings
            var outerRingCoordinates: [CLLocationCoordinate2D] = []
            var innerRings: [MKPolygon] = []

            for (index, ringCoordinates) in coordinatesArray.enumerated() {
                var coords: [CLLocationCoordinate2D] = []
                for coordinate in ringCoordinates {
                    if coordinate.count >= 2 {
                        let longitude = coordinate[0]
                        let latitude = coordinate[1]
                        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        coords.append(coord)
                    }
                }
                if !coords.isEmpty {
                    if index == 0 {
                        // Outer ring
                        outerRingCoordinates = coords
                    } else {
                        // Inner rings (holes)
                        let interiorPolygon = MKPolygon(coordinates: coords, count: coords.count)
                        innerRings.append(interiorPolygon)
                    }
                }
            }

            if !outerRingCoordinates.isEmpty {
                let polygon = MKPolygon(coordinates: outerRingCoordinates, count: outerRingCoordinates.count, interiorPolygons: innerRings)
                return polygon
            }
        case .point(_):
            // Handle point if needed
            return nil
        case .invalid:
            return nil
        }
        return nil
    }
    
    // MARK:  - Recenter on municipality
    func recenter(to municipio: Municipio) {
                // Calculate the centroid of the municipio's geometry
        guard let geometry = municipio.geometry,
              let centroid = calculateCentroid(of: geometry) else {
            print("Unable to calculate centroid for municipio: \(municipio.displayFullName)")
            return
        }
        
        // Create a new region centered at the centroid with an appropriate zoom level
        let newRegion = MKCoordinateRegion(center: centroid, latitudinalMeters: 50000, longitudinalMeters: 50000)
        
        // Update the map's region to center on the new municipio
        DispatchQueue.main.async {
            self.region = newRegion
        }
    }

    private func calculateCentroid(of geometry: Geometry) -> CLLocationCoordinate2D? {
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

