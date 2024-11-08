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
            MapLayer(name: "Estaciones de Policias", type: .pointsOfInterest("Police")),
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

    // Dictionaries to associate overlays and annotations with layers
    var layerOverlays: [UUID: [MKOverlay]] = [:]
    var layerAnnotations: [UUID: [MKAnnotation]] = [:]

    // Modify addLayer and removeLayer methods
    func addLayer(_ layer: MapLayer) {
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

    func removeLayer(_ layer: MapLayer) {
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
    func loadGeoJSONOverlay(fileName: String) -> [MKOverlay] {
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
    func search(for query: String, completion: @escaping ([MKAnnotation]) -> Void) {
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
    
    // MARK:  - Recenter on municipality
    func recenter(to municipio: Municipio) {
        // Obtener las coordenadas del municipio utilizando el enum
        let coordinates = municipio.coordinates
        
        // Crear una nueva región centrada en el municipio con un nivel de zoom adecuado
        let newRegion = MKCoordinateRegion(
            center: coordinates,
            latitudinalMeters: 5000, // 1000 metros de altura
            longitudinalMeters: 5000 // 1000 metros de anchura
        )
        
        // Actualizar la región del mapa para centrarse en el nuevo municipio
        self.region = newRegion
    }
}

