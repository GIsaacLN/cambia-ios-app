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
            MapLayer(name: "Flood Zones", type: .geoJSON(floodZonesFile)),
            MapLayer(name: "Landslide Zones", type: .geoJSON(landslideZonesFile)),
            MapLayer(name: "Tsunami Zones", type: .geoJSON(tsunamiZonesFile)),
            MapLayer(name: "Active Volcanoes", type: .geoJSON(volcanoZonesFile)),
            MapLayer(name: "Hospitals", type: .pointsOfInterest("Hospital")),
            MapLayer(name: "Police Stations", type: .pointsOfInterest("Police")),
            MapLayer(name: "Fire Stations", type: .pointsOfInterest("Fire Station"))
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
                var strokeColor: UIColor = .blue
                var lineWidth: CGFloat = 2.0

                // Personalización de colores según el tipo de capa
                switch fileName {
                case floodZonesFile:
                    fillColor = .blue.withAlphaComponent(0.3)
                    strokeColor = .blue
                case landslideZonesFile:
                    fillColor = .brown.withAlphaComponent(0.4)
                    strokeColor = .brown
                case tsunamiZonesFile:
                    fillColor = .cyan.withAlphaComponent(0.4)
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
}

