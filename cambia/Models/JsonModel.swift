//
//  JsonModel.swift
//  cambia
//
//  Created by Raymundo Mondragon Lara on 06/11/24.
//

import Foundation

// Top-level struct for GeoJSON format
struct GeoJSON: Codable {
    let type: String
    let features: [Feature]
}

// Each feature in the GeoJSON
struct Feature: Codable {
    let type: String
    let properties: Properties
}

enum Coordinates: Codable {
    case point([Double])
    case polygon([[[Double]]])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Attempt to decode as a point (single array with doubles)
        if let point = try? container.decode([Double].self) {
            self = .point(point)
            return
        }
        
        // Attempt to decode as a polygon (multi-dimensional array)
        if let polygon = try? container.decode([[[Double]]].self) {
            self = .polygon(polygon)
            return
        }
        
        throw DecodingError.typeMismatch(
            Coordinates.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Coordinates could not be decoded as point or polygon."
            )
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .point(let point):
            try container.encode(point)
        case .polygon(let polygon):
            try container.encode(polygon)
        }
    }
}




struct Properties: Codable {
    let nomMun: String?
    let oid1: Int?
    let cveMpio: String?
    let iviEstad: String?
    let iviPob20: Int?
    let umbral12h: Double?
    let iviVulne: String?
    let municipio: String
    let umbral: Double?
    let areaKm: Double?
    let areaInun: Double?
    let porcentaje: Double?
    let peligroIn: String?
    
    private enum CodingKeys: String, CodingKey {
        case nomMun = "NOM_MUN"
        case oid1 = "OID_1"
        case cveMpio = "CVE_MPIO"
        case iviEstad = "IVI_ESTAD"
        case iviPob20 = "IVI_POB20"
        case umbral12h = "UMBRAL12H"
        case iviVulne = "IVI__VULNE"
        case municipio = "MUNICIPIO"
        case umbral = "UMBRAL"
        case areaKm = "AREAKMKM"
        case areaInun = "ÁREA_INUN"
        case porcentaje = "PORCENTA_1"
        case peligroIn = "PELIGRO_IN"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nomMun = try? container.decode(String.self, forKey: .nomMun)
        oid1 = try? container.decode(Int.self, forKey: .oid1)
        iviEstad = try? container.decode(String.self, forKey: .iviEstad)
        iviPob20 = try? container.decode(Int.self, forKey: .iviPob20)
        umbral12h = try? container.decode(Double.self, forKey: .umbral12h)
        iviVulne = try? container.decode(String.self, forKey: .iviVulne)
        municipio = try container.decode(String.self, forKey: .municipio)
        umbral = try? container.decode(Double.self, forKey: .umbral)
        areaKm = try? container.decode(Double.self, forKey: .areaKm)
        areaInun = try? container.decode(Double.self, forKey: .areaInun)
        porcentaje = try? container.decode(Double.self, forKey: .porcentaje)
        peligroIn = try? container.decode(String.self, forKey: .peligroIn)
        
        // Handle CVE_MPIO as either Int or String
        if let intValue = try? container.decode(Int.self, forKey: .cveMpio) {
            cveMpio = String(intValue)
        } else {
            cveMpio = try? container.decode(String.self, forKey: .cveMpio)
        }
    }
}
