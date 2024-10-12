//
//  MapViewModel.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

import SwiftUI
import MapKit

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
            MapLayer(name: "Flood Zones", type: .geoJSON("inundacionmunicipio")),
            MapLayer(name: "Hospitals", type: .pointsOfInterest("Hospital")),
            MapLayer(name: "Police Stations", type: .pointsOfInterest("Police")),
            MapLayer(name: "Fire Stations", type: .pointsOfInterest("Fire Station"))
            // Add more layers as needed
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
            newOverlays = parseGeoJSON(geoJSONObjects)
        } catch {
            print("Error loading GeoJSON: \(error)")
        }

        return newOverlays
    }

    private func parseGeoJSON(_ geoJSONObjects: [MKGeoJSONObject]) -> [MKOverlay] {
        var overlays: [MKOverlay] = []

        for object in geoJSONObjects {
            if let feature = object as? MKGeoJSONFeature {
                var fillColor: UIColor = UIColor.red.withAlphaComponent(0.5)
                var strokeColor: UIColor = UIColor.blue
                var lineWidth: CGFloat = 2.0

                // Extract properties if needed
                if let propertiesData = feature.properties,
                   let properties = try? JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any] {

                    // Example: Change color based on a property
                    if let dangerLevel = properties["PELIGRO_IN"] as? String {
                        switch dangerLevel {
                        case "Muy bajo":
                            fillColor = UIColor.green.withAlphaComponent(0.5)
                        case "Bajo":
                            fillColor = UIColor.yellow.withAlphaComponent(0.5)
                        case "Medio":
                            fillColor = UIColor.orange.withAlphaComponent(0.5)
                        case "Alto":
                            fillColor = UIColor.red.withAlphaComponent(0.5)
                        default:
                            fillColor = UIColor.gray.withAlphaComponent(0.5)
                        }
                    }
                }

                for geometry in feature.geometry {
                    if let polygon = geometry as? MKPolygon {
                        // Create a StyledPolygon with the styling information
                        let styledPolygon = StyledPolygon(points: polygon.points(), count: polygon.pointCount)
                        styledPolygon.fillColor = fillColor
                        styledPolygon.strokeColor = strokeColor
                        styledPolygon.lineWidth = lineWidth

                        overlays.append(styledPolygon)
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
        request.region = region // Use the current region

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
