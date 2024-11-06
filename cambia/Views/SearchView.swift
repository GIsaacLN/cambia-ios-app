//
//  SearchView.swift
//  cambia
//
//  Created by yatziri on 26/10/24.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @Binding var isSearching: Bool
    @Binding var searchText: String
    
    var body: some View {
        ZStack {
            Color.gray6.opacity(0.7)
                .cornerRadius(20)
            TextField("\(Image(systemName: "magnifyingglass"))  Buscar Ciudad o Municipio", text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 7.5)
        }
        .padding()
    }
}

// SearchlistView para mostrar los resultados de búsqueda
struct SearchlistView: View {
    @Binding var isSearching: Bool
    @Binding var searchText: String
    @Binding var filteredCities: [Ciudad]
    @Binding var filteredMunicipios: [Municipio]
    
    @EnvironmentObject var viewModel: CiudadMunicipioViewModel
    
    var body: some View {
        let totalItems = filteredCities.count + filteredMunicipios.count
        let rowHeight: CGFloat = 100 // Altura de cada fila
        let maxHeight: CGFloat = 1000 // Altura máxima de la lista
        
        // Calcular la altura de la lista en función del número de elementos, con un límite de 400
        let listHeight = min(CGFloat(totalItems) * rowHeight, maxHeight)
        
        VStack(alignment: .leading) {
            List {
                if !filteredCities.isEmpty {
                    Section(header: Text("Ciudades Encontradas")) {
                        ForEach(filteredCities, id: \.self) { city in
                            Button {
                                viewModel.updateCityMunicipality(for: city, to: nil)
                                
                                searchText = ""
                                isSearching = false
                                filteredCities = []
                                filteredMunicipios = []
                            } label: {
                                HStack {
                                    Text(city.displayName)
                                    Spacer()
                                    
                                }
                            }
                        }.listRowBackground(Color("gray5"))
                    }
                }
                
                if !filteredMunicipios.isEmpty {
                    Section(header: Text("Municipios Encontrados")) {
                        ForEach(filteredMunicipios, id: \.self) { municipio in
                            Button {
                                viewModel.updateMunicipality(to: municipio)
                                searchText = ""
                                isSearching = false
                                filteredCities = []
                                filteredMunicipios = []
                            } label: {
                                HStack {
                                    Text(municipio.displayName)
                                    Spacer()
                                }
                            }
                        }.listRowBackground(Color("gray5"))
                    }
                }
                
                if filteredCities.isEmpty && filteredMunicipios.isEmpty && !searchText.isEmpty {
                    Text("No se encontraron resultados.")
                        .foregroundColor(.gray)
                }
            }
            .frame(height: listHeight) // Ajustar la altura de la lista
            .listStyle(.plain)
        }
        .background(searchText.isEmpty ? Color.white.opacity(0) : Color("gray5"))
        .cornerRadius(20)
        .padding(.vertical)
        .padding()
        .padding(.top)
    }
}


// Extensiones para agregar nombres amigables a las ciudades y municipios
extension Ciudad {
    var displayName: String {
        switch self {
        case .ciudadDeMexico: return "Ciudad de México"
        }
    }
}

extension Municipio {
    var displayName: String {
        switch self {
        case .azcapotzalco: return "Azcapotzalco"
        case .BenitoJuarez: return "Benito Juárez"
        case .Coyoacan: return "Coyoacán"
        case .CuajimalpaDeMorelos: return "Cuajimalpa de Morelos"
        case .Cuauhtemoc: return "Cuauhtémoc"
        case .GustavoAMadero: return "Gustavo A. Madero"
        case .Iztacalco: return "Iztacalco"
        case .Iztapalapa: return "Iztapalapa"
        case .LaMagdalenaContreras: return "La Magdalena Contreras"
        case .MiguelHidalgo: return "Miguel Hidalgo"
        case .MilpaAlta: return "Milpa Alta"
        case .Tlalpan: return "Tlalpan"
        case .Tlahuac: return "Tláhuac"
        case .VenustianoCarranza: return "Venustiano Carranza"
        case .Xochimilco: return "Xochimilco"
        case .AlvaroObregon: return "Álvaro Obregón"
        }
    }
    
    var coordinates: CLLocationCoordinate2D {
        switch self {
        case .azcapotzalco: return CLLocationCoordinate2D(latitude: 19.48698, longitude: -99.18594)
        case .BenitoJuarez: return CLLocationCoordinate2D(latitude: 19.3727, longitude: -99.1564)
        case .Coyoacan: return CLLocationCoordinate2D(latitude: 19.3467, longitude: -99.16174)
        case .CuajimalpaDeMorelos: return CLLocationCoordinate2D(latitude: 19.3692, longitude: -99.29089)
        case .Cuauhtemoc: return CLLocationCoordinate2D(latitude: 19.44506, longitude: -99.14612)
        case .GustavoAMadero: return CLLocationCoordinate2D(latitude: 19.4, longitude: -99.1)
        case .Iztacalco: return CLLocationCoordinate2D(latitude: 19.39528, longitude: -99.09778)
        case .Iztapalapa: return CLLocationCoordinate2D(latitude: 19.4, longitude: -99.14)
        case .LaMagdalenaContreras: return CLLocationCoordinate2D(latitude: 19.333333333333, longitude: -99.213888888889)
        case .MiguelHidalgo: return CLLocationCoordinate2D(latitude: 19.43411, longitude: -99.20024)
        case .MilpaAlta: return CLLocationCoordinate2D(latitude: 19.19251, longitude: -99.02317)
        case .Tlalpan: return CLLocationCoordinate2D(latitude: 19.29513, longitude: -99.16206)
        case .Tlahuac: return CLLocationCoordinate2D(latitude: 19.28689, longitude: -99.00507)
        case .VenustianoCarranza: return CLLocationCoordinate2D(latitude: 19.44361, longitude: -99.10499)
        case .Xochimilco: return CLLocationCoordinate2D(latitude: 19.25465, longitude: -99.10356)
        case .AlvaroObregon: return CLLocationCoordinate2D(latitude: 19.35867, longitude: -99.20329)
        }
    }
}

/*#Preview {
    SearchView(isSearching: .constant(true), searchText: .constant(""))
}*/
