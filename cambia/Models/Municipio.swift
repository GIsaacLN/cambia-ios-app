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
    
    var nombre: String?
    var clave: String?
    var estado: String?
    var coordinates: CLLocationCoordinate2D?
    
    var displayFullName: String {
        let name = nombre ?? ""
        let state = estado ?? ""
        
        if !name.isEmpty && !state.isEmpty {
            return "\(name), \(state)"
        } else {
            return name.isEmpty ? state : name
        }
    }
}

