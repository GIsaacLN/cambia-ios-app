//
//  Municipio.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 08/11/24.
//

import Foundation
import CoreLocation

struct Municipio: Identifiable {
    var id: UUID = UUID()
    
    var nombre: String?
    var clave: String?
    var estado: String?
    var coordinates: CLLocationCoordinate2D?
    var geometry: Geometry?
    
    // Additional properties for metrics
    var cityArea: Double?
    var inundatedArea: Double?
    var populationVulnerability: Int?
    var vulnerabilityIndex: String?
    var floodHazardLevel: String?
    var threshold12h: Double?
    
    init(nombre: String? = nil, clave: String? = nil, estado: String? = nil, coordinates: CLLocationCoordinate2D? = nil, geometry: Geometry? = nil, cityArea: Double? = nil, inundatedArea: Double? = nil, populationVulnerability: Int? = nil, vulnerabilityIndex: String? = nil, floodHazardLevel: String? = nil, threshold12h: Double? = nil) {
        self.nombre = nombre
        self.clave = clave
        self.estado = estado
        self.coordinates = coordinates
        self.geometry = geometry
        self.cityArea = cityArea
        self.inundatedArea = inundatedArea
        self.populationVulnerability = populationVulnerability
        self.vulnerabilityIndex = vulnerabilityIndex
        self.floodHazardLevel = floodHazardLevel
        self.threshold12h = threshold12h
    }
    
    var displayFullName: String {
        switch (nombre, estado) {
        case let (name?, state?) where !name.isEmpty && !state.isEmpty:
            return "\(name), \(state)"
        case let (name?, _) where !name.isEmpty:
            return name
        case let (_, state?) where !state.isEmpty:
            return state
        default:
            return ""
        }
    }
}
