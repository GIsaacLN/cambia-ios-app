//
//  Municipio.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 08/11/24.
//

import Foundation
import CoreLocation

struct Municipio: Identifiable {
    let id: UUID
    
    var displayName: String?
    var clave: String?
    
    var coordinates: CLLocationCoordinate2D?
}

