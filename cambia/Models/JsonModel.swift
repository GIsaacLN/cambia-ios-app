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
    let NOM_MUN: String?
    let OID_1: Int?
    let CVE_MPIO: String?
    let IVI_ESTAD: String?
    let IVI_POB20: Int?
    let UMBRAL12H: Double?
    let IVI_VULNE: String?
    let MUNICIPIO: String
    let UMBRAL: Double?
    let AREAKMKM: Double?
    let ÁREA_INUN: Double?
    let PORCENTA_1: Double?
    let PELIGRO_IN: String?

    private enum CodingKeys: String, CodingKey {
        case NOM_MUN, OID_1, CVE_MPIO, IVI_ESTAD, IVI_POB20, UMBRAL12H, IVI_VULNE, MUNICIPIO, UMBRAL, AREAKMKM, ÁREA_INUN, PORCENTA_1, PELIGRO_IN
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        NOM_MUN = try? container.decode(String.self, forKey: .NOM_MUN)
        OID_1 = try? container.decode(Int.self, forKey: .OID_1)
        IVI_ESTAD = try? container.decode(String.self, forKey: .IVI_ESTAD)  // Make optional
        IVI_POB20 = try? container.decode(Int.self, forKey: .IVI_POB20)    // Make optional
        UMBRAL12H = try? container.decode(Double.self, forKey: .UMBRAL12H)
        IVI_VULNE = try? container.decode(String.self, forKey: .IVI_VULNE)  // Make optional
        MUNICIPIO = try container.decode(String.self, forKey: .MUNICIPIO)
        UMBRAL = try? container.decode(Double.self, forKey: .UMBRAL)         // Make optional
        AREAKMKM = try? container.decode(Double.self, forKey: .AREAKMKM)
        ÁREA_INUN = try? container.decode(Double.self, forKey: .ÁREA_INUN)
        PORCENTA_1 = try? container.decode(Double.self, forKey: .PORCENTA_1) // Make optional
        PELIGRO_IN = try? container.decode(String.self, forKey: .PELIGRO_IN) // Make optional

        // Handle CVE_MPIO as either Int or String
        if let intValue = try? container.decode(Int.self, forKey: .CVE_MPIO) {
            CVE_MPIO = String(intValue)
        } else {
            CVE_MPIO = try container.decode(String.self, forKey: .CVE_MPIO)
        }
    }
}
