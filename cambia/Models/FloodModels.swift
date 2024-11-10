//
//  FloodModels.swift
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
    let geometry: Geometry
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

// Geometry struct for polygon coordinates
struct Geometry: Codable {
    let type: String
    let coordinates: Coordinates
    
    enum Coordinates: Codable {
        case point([Double])
        case polygon([[[Double]]])
        case invalid
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            // Try decoding as a single point (array of doubles)
            if let point = try? container.decode([Double].self) {
                self = .point(point)
                return
            }
            
            // Try decoding as a polygon (3D array)
            if let polygon = try? container.decode([[[Double]]].self) {
                self = .polygon(polygon)
                return
            }
            
            // Fallback if the structure is unexpected
            self = .invalid
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .point(let point):
                try container.encode(point)
            case .polygon(let polygon):
                try container.encode(polygon)
            case .invalid:
                throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Invalid coordinate type"))
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
    }
}

struct Properties: Codable {
    let nomMun: String?
    let oid1: Int?
    let cveMpio: Int?
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
    let clv: String?
    
    private enum CodingKeys: String, CodingKey {
        case nomMun = "NOM_MUN"
        case oid1 = "OID_1"
        case cveMpio = "CVE_MPIO"
        case iviEstad = "IVI__ESTAD"
        case iviPob20 = "IVI__POB20"
        case umbral12h = "UMBRAL12H"
        case iviVulne = "IVI__VULNE"
        case municipio = "MUNICIPIO"
        case umbral = "UMBRAL"
        case areaKm = "AREAKMKM"
        case areaInun = "ÁREA_INUN"
        case porcentaje = "PORCENTA_1"
        case peligroIn = "PELIGRO_IN"
        case clv = "CLV"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nomMun = try? container.decode(String.self, forKey: .nomMun)
        oid1 = try? container.decode(Int.self, forKey: .oid1)
        cveMpio = try? container.decode(Int.self, forKey: .cveMpio)
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
        clv = try? container.decode(String.self, forKey: .clv)

    }
}
