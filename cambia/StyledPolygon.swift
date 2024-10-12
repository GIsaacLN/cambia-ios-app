//
//  StyledPolygon.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

import MapKit

class StyledPolygon: MKPolygon {
    var fillColor: UIColor = UIColor.red.withAlphaComponent(0.5)
    var strokeColor: UIColor = UIColor.blue
    var lineWidth: CGFloat = 2.0
}
