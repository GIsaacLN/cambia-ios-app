//
//  MKPolygon+Contains.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 12/10/24.
//

import MapKit

extension MKPolygon {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let renderer = MKPolygonRenderer(polygon: self)
        let mapPoint = MKMapPoint(coordinate)
        let point = renderer.point(for: mapPoint)
        return renderer.path.contains(point)
    }
}
