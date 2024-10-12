//
//  MapLayer.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

import Foundation
import MapKit

struct MapLayer: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let type: LayerType

    enum LayerType: Equatable {
        case geoJSON(String) // Filename
        case pointsOfInterest(String) // Search query
    }

    static func == (lhs: MapLayer, rhs: MapLayer) -> Bool {
        return lhs.id == rhs.id
    }
}

extension MKPolygon {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let renderer = MKPolygonRenderer(polygon: self)
        let mapPoint = MKMapPoint(coordinate)
        let point = renderer.point(for: mapPoint)
        return renderer.path.contains(point)
    }
}
