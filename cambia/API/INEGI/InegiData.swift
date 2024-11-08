//
//  InegiData.swift
//  AppiPrueba1
//
//  Created by yatziri on 26/10/24.
//

import Foundation

struct InegiData: Codable, Equatable {
    let estado: String
    let municipio: String
    var indicators: [String: Double]
}

// Estructura principal para el JSON recibido
struct InegiDataResponse: Codable {
    let header: Header
    let series: [Serie]
    
    // Definir las keys de acuerdo con la estructura JSON
    private enum CodingKeys: String, CodingKey {
        case header = "Header"
        case series = "Series"
    }
    
    func toInegiData(estado: String, municipio: String) -> InegiData {
        var indicators = [String: Double]()
        
        for serie in series {
            // Convierte el valor de observación a Double
            if let obsValue = Double(serie.observations.first?.obsValue ?? "") {
                switch serie.indicador {
                case IndicatorType.poblacionTotal.rawValue:
                    indicators["poblacionTotal"] = obsValue
                case IndicatorType.densidad.rawValue:
                    indicators["densidad"] = obsValue
                case IndicatorType.viviendasConAgua.rawValue:
                    indicators["viviendasConAgua"] = obsValue
                case IndicatorType.viviendasConElectricidad.rawValue:
                    indicators["viviendasConElectricidad"] = obsValue
                default:
                    // Manejo de otros indicadores en el futuro
                    indicators[serie.indicador] = obsValue
                }
            }
        }
        
        return InegiData(estado: estado, municipio: municipio, indicators: indicators)
    }
}

// Estructura para el header
struct Header: Codable {
    let name: String
    let email: String
    
    // Definir las keys para las propiedades que no coinciden
    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case email = "Email"
    }
}

// Estructura para cada Serie en el JSON
struct Serie: Codable {
    let indicador: String
    let freq: String
    let topic: String
    let unit: String
    let unitMult: String?
    let note: String
    let source: String
    let lastUpdate: String
    let status: String?
    let observations: [Observation]
    
    private enum CodingKeys: String, CodingKey {
        case indicador = "INDICADOR"
        case freq = "FREQ"
        case topic = "TOPIC"
        case unit = "UNIT"
        case unitMult = "UNIT_MULT"
        case note = "NOTE"
        case source = "SOURCE"
        case lastUpdate = "LASTUPDATE"
        case status = "STATUS"
        case observations = "OBSERVATIONS"
    }
}

// Estructura para cada Observation dentro de Serie
struct Observation: Codable {
    let timePeriod: String
    let obsValue: String
    let obsException: String?
    let obsStatus: String
    let obsSource: String
    let obsNote: String
    let coberGeo: String
    
    private enum CodingKeys: String, CodingKey {
        case timePeriod = "TIME_PERIOD"
        case obsValue = "OBS_VALUE"
        case obsException = "OBS_EXCEPTION"
        case obsStatus = "OBS_STATUS"
        case obsSource = "OBS_SOURCE"
        case obsNote = "OBS_NOTE"
        case coberGeo = "COBER_GEO"
    }
}
