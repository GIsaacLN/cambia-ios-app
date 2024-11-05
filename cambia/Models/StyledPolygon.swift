//
//  StyledPolygon.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 11/10/24.
//

import MapKit

class StyledPolygon: MKPolygon {
    var fillColor: UIColor = UIColor.red.withAlphaComponent(0.5)
    var strokeColor: UIColor = UIColor.white
    var lineWidth: CGFloat = 1.0
}
