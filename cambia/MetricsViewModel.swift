//
//  MetricsViewModel.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

import SwiftUI
import MapKit

class MetricsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var overlays: [StyledPolygon] = []
    @Published var region: MKCoordinateRegion
    @Published var searchResults: [MKMapItem] = []
    
    // Action triggers
    @Published var zoomInTrigger: Bool = false
    @Published var zoomOutTrigger: Bool = false
    @Published var showUserLocationTrigger: Bool = false
    @Published var togglePitchTrigger: Bool = false
    
    // MARK: - Initialization
    init() {
        // Initialize the default region (Ciudad de México)
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        // Load overlays
        loadOverlays()
    }
    
    // MARK: - Overlay Loading
    func loadOverlays() {
        guard let jsonUrl = Bundle.main.url(forResource: "inundacionmunicipio", withExtension: "json") else {
            print("GeoJSON file not found")
            return
        }
        
        do {
            let jsonData = try Data(contentsOf: jsonUrl)
            let decoder = MKGeoJSONDecoder()
            let geoJSONObjects = try decoder.decode(jsonData)
            parseGeoJSON(geoJSONObjects)
        } catch {
            print("Error loading GeoJSON: \(error)")
        }
    }
    
    private func parseGeoJSON(_ geoJSONObjects: [MKGeoJSONObject]) {
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

                        DispatchQueue.main.async {
                            self.overlays.append(styledPolygon)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Search Functionality
    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = region // Use the current region
        
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            DispatchQueue.main.async {
                self.searchResults = response?.mapItems ?? []
            }
        }
    }
    
    // MARK: - Map Actions
    func performZoomIn() {
        var newRegion = region
        newRegion.span.latitudeDelta /= 2.0
        newRegion.span.longitudeDelta /= 2.0
        region = newRegion
    }
    
    func performZoomOut() {
        var newRegion = region
        newRegion.span.latitudeDelta *= 2.0
        newRegion.span.longitudeDelta *= 2.0
        region = newRegion
    }
}
