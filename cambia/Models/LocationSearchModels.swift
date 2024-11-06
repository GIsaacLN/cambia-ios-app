//
//  LocationSearchModels.swift
//  cambia
//
//  Created by yatziri on 26/10/24.
//

import Foundation

enum IndicatorType: String, CaseIterable {
    case poblacionTotal = "1002000001"
    case densidad = "3105001001"
    case viviendasConAgua = "3114005001"
    case viviendasConElectricidad = "3114006001"
}

enum Ciudad: String, CaseIterable {
    case ciudadDeMexico = "07000009"
}

enum Municipio: String, CaseIterable{
    case azcapotzalco = "0002"
    case BenitoJuarez = "0014"
    case Coyoacan = "0003"
    case CuajimalpaDeMorelos = "0004"
    case Cuauhtemoc = "002"
    case GustavoAMadero = "0005"
    case Iztacalco = "0006"
    case Iztapalapa = "0007"
    case LaMagdalenaContreras = "0008"
    case MiguelHidalgo = "0016"
    case MilpaAlta = "0009"
    case Tlalpan = "0012"
    case Tlahuac = "0011"
    case VenustianoCarranza = "0017"
    case Xochimilco = "0013"
    case AlvaroObregon = "0010"
}



// Estructura que conecta ciudad con sus municipios
struct CiudadMunicipios {
    let ciudad: Ciudad
    let municipios: [Municipio?]
}

// Definición de los municipios para cada ciudad
let RelacionCiudadMunicipios: [CiudadMunicipios] = [
    CiudadMunicipios(ciudad: .ciudadDeMexico, municipios: [
        .azcapotzalco, .BenitoJuarez, .Coyoacan, .CuajimalpaDeMorelos, .Cuauhtemoc, .GustavoAMadero,
        .Iztacalco, .Iztapalapa, .LaMagdalenaContreras, .MiguelHidalgo, .MilpaAlta, .Tlalpan,
        .Tlahuac, .VenustianoCarranza, .Xochimilco, .AlvaroObregon
    ])
]

// Estructura que conecta ciudad con sus municipios
struct SelectCiudadMunicipio {
    var ciudad: Ciudad
    var municipios: Municipio?
    init(ciudad: Ciudad, municipios: Municipio? = nil) {
        self.ciudad = ciudad
        self.municipios = municipios
    }
}

// ViewModel que almacena un CityMunicipality observable
class CiudadMunicipioViewModel: ObservableObject {
    @Published var selectedCiudadMunicipio: SelectCiudadMunicipio = SelectCiudadMunicipio(ciudad: .ciudadDeMexico, municipios: .azcapotzalco) // Conformidad a Equatable
    
    // Función para actualizar el CityMunicipality en función de la ciudad seleccionada
    func updateCityMunicipality(for ciudad: Ciudad, to municipio: Municipio?) {
        selectedCiudadMunicipio = SelectCiudadMunicipio(ciudad: ciudad, municipios: municipio)
    }
    // Función para actualizar el CityMunicipality en función de la ciudad seleccionada
    func updateMunicipality(to municipio: Municipio?) {
        selectedCiudadMunicipio.municipios = municipio!
    }
    func textselectedCiudadMunicipio(for ciudad: Ciudad, to municipio: Municipio?)->String{
        var text: String = "\(ciudad.displayName)"
        if let mun = municipio {
            text.append(String(", \(mun.displayName)"))
        }
        return text
    }
}
