//
//  LocationSearchModels.swift
//  cambia
//
//  Created by yatziri on 26/10/24.
//

import Foundation
import CoreLocation

enum IndicatorType: String, CaseIterable {
    case poblacionTotal = "1002000001"
    case densidad = "3105001001"
    case viviendasConAgua = "3114005001"
    case viviendasConElectricidad = "3114006001"
}

enum Estado: String, CaseIterable {
    case ciudadDeMexico = "07000009"
    case michoacan = ""
}

enum Municipio: String, CaseIterable {
    case azcapotzalco = "0002"
    case benitoJuarez = "0014"
    case coyoacan = "0003"
    case cuajimalpaDeMorelos = "0004"
    case cuauhtemoc = "002"
    case gustavoAMadero = "0005"
    case iztacalco = "0006"
    case iztapalapa = "0007"
    case laMagdalenaContreras = "0008"
    case miguelHidalgo = "0016"
    case milpaAlta = "0009"
    case tlalpan = "0012"
    case tlahuac = "0011"
    case venustianoCarranza = "0017"
    case xochimilco = "0013"
    case alvaroObregon = "0010"
    
    var jsonFormattedName: String {
        switch self {
        case .azcapotzalco: return "AZCAPOTZALCO"
        case .benitoJuarez: return "BENITO JUAREZ"
        case .coyoacan: return "COYOACAN"
        case .cuajimalpaDeMorelos: return "CUAJIMALPA DE MORELOS"
        case .cuauhtemoc: return "CUAUHTEMOC"
        case .gustavoAMadero: return "GUSTAVO A MADERO"
        case .iztacalco: return "IZTACALCO"
        case .iztapalapa: return "IZTAPALAPA"
        case .laMagdalenaContreras: return "LA MAGDALENA CONTRERAS"
        case .miguelHidalgo: return "MIGUEL HIDALGO"
        case .milpaAlta: return "MILPA ALTA"
        case .tlalpan: return "TLALPAN"
        case .tlahuac: return "TLAHUAC"
        case .venustianoCarranza: return "VENUSTIANO CARRANZA"
        case .xochimilco: return "XOCHIMILCO"
        case .alvaroObregon: return "ALVARO OBREGON"
        }
    }
    
    var coordinates: CLLocationCoordinate2D {
        switch self {
        case .azcapotzalco: return CLLocationCoordinate2D(latitude: 19.48698, longitude: -99.18594)
        case .benitoJuarez: return CLLocationCoordinate2D(latitude: 19.3727, longitude: -99.1564)
        case .coyoacan: return CLLocationCoordinate2D(latitude: 19.3467, longitude: -99.16174)
        case .cuajimalpaDeMorelos: return CLLocationCoordinate2D(latitude: 19.3692, longitude: -99.29089)
        case .cuauhtemoc: return CLLocationCoordinate2D(latitude: 19.44506, longitude: -99.14612)
        case .gustavoAMadero: return CLLocationCoordinate2D(latitude: 19.4969, longitude: -99.1100)
        case .iztacalco: return CLLocationCoordinate2D(latitude: 19.39528, longitude: -99.09778)
        case .iztapalapa: return CLLocationCoordinate2D(latitude: 19.3574, longitude: -99.0671)
        case .laMagdalenaContreras: return CLLocationCoordinate2D(latitude: 19.3333, longitude: -99.2139)
        case .miguelHidalgo: return CLLocationCoordinate2D(latitude: 19.43411, longitude: -99.20024)
        case .milpaAlta: return CLLocationCoordinate2D(latitude: 19.19251, longitude: -99.02317)
        case .tlalpan: return CLLocationCoordinate2D(latitude: 19.29513, longitude: -99.16206)
        case .tlahuac: return CLLocationCoordinate2D(latitude: 19.28689, longitude: -99.00507)
        case .venustianoCarranza: return CLLocationCoordinate2D(latitude: 19.44361, longitude: -99.10499)
        case .xochimilco: return CLLocationCoordinate2D(latitude: 19.25465, longitude: -99.10356)
        case .alvaroObregon: return CLLocationCoordinate2D(latitude: 19.35867, longitude: -99.20329)
        }
    }
}

// Structure connecting city with its municipalities
struct EstadoMunicipios {
    let estado: Estado
    let municipios: [Municipio]
}

// Definition of municipalities for each city
let relacionEstadoMunicipios: [EstadoMunicipios] = [
    EstadoMunicipios(estado: .ciudadDeMexico, municipios: Municipio.allCases)
]

// Structure connecting selected city with its municipality
struct SelectEstadoMunicipio {
    var estado: Estado
    var municipios: Municipio?
    
    init(estado: Estado, municipios: Municipio? = nil) {
        self.estado = estado
        self.municipios = municipios
    }
}

// ViewModel storing an observable CityMunicipality
class EstadoMunicipioViewModel: ObservableObject {
    @Published var selectedEstadoMunicipio: SelectEstadoMunicipio = SelectEstadoMunicipio(estado: .ciudadDeMexico, municipios: .azcapotzalco)
    
    // Function to update CityMunicipality based on selected city
    func updateCityMunicipality(for estado: Estado, to municipio: Municipio?) {
        selectedEstadoMunicipio = SelectEstadoMunicipio(estado: estado, municipios: municipio)
    }
    
    // Function to update the municipality
    func updateMunicipality(to municipio: Municipio?) {
        selectedEstadoMunicipio.municipios = municipio
    }
    
    // Function to get the display text for selected city and municipality
    func textSelectedEstadoMunicipio(for estado: Estado, to municipio: Municipio?) -> String {
        var text = "\(estado.displayName)"
        if let mun = municipio {
            text.append(", \(mun.displayName)")
        }
        return text
    }
}

// Extensions for display names
extension Estado {
    var displayName: String {
        switch self {
        case .ciudadDeMexico: return "Ciudad de México"
        case .michoacan: return "Michoacán"
        }
    }
}

extension Municipio {
    var displayName: String {
        switch self {
        case .azcapotzalco: return "Azcapotzalco"
        case .benitoJuarez: return "Benito Juárez"
        case .coyoacan: return "Coyoacán"
        case .cuajimalpaDeMorelos: return "Cuajimalpa de Morelos"
        case .cuauhtemoc: return "Cuauhtémoc"
        case .gustavoAMadero: return "Gustavo A. Madero"
        case .iztacalco: return "Iztacalco"
        case .iztapalapa: return "Iztapalapa"
        case .laMagdalenaContreras: return "La Magdalena Contreras"
        case .miguelHidalgo: return "Miguel Hidalgo"
        case .milpaAlta: return "Milpa Alta"
        case .tlalpan: return "Tlalpan"
        case .tlahuac: return "Tláhuac"
        case .venustianoCarranza: return "Venustiano Carranza"
        case .xochimilco: return "Xochimilco"
        case .alvaroObregon: return "Álvaro Obregón"
        }
    }
}
