//
//  SearchView.swift
//  cambia
//
//  Created by yatziri on 26/10/24.
//

import SwiftUI
import SwiftUI

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var filteredCities: [Ciudad] = []
    @State private var filteredMunicipios: [Municipio] = []
    
    @EnvironmentObject var viewModel : CiudadMunicipioViewModel
    
    var body: some View {
        //Text("\(viewModel.selectedCiudadMunicipio)")
        VStack {
            TextField("Buscar Ciudad o Municipio", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: searchText) { _ in
                    filterResults() // Filtrar resultados en tiempo real
                }
            
            List {
                if !filteredCities.isEmpty {
                    Section(header: Text("Ciudades Encontradas")) {
                        ForEach(filteredCities, id: \.self) { city in
                            Button {
                                viewModel.updateCityMunicipality(for: city, to: nil)
                            } label: {
                                HStack {
                                    Text(city.displayName)
                                    Spacer()
                                    
                                }
                            }

                            
                        }
                    }
                }
                
                if !filteredMunicipios.isEmpty {
                    Section(header: Text("Municipios Encontrados")) {
                        ForEach(filteredMunicipios, id: \.self) { municipio in
                            Button {
                                viewModel.updateMunicipality( to: municipio)
                            } label: {
                                HStack {
                                    Text(municipio.displayName)
                                    Spacer()
                                    
                                }
                            }
                            
                        }
                    }
                }
                
                if filteredCities.isEmpty && filteredMunicipios.isEmpty && !searchText.isEmpty {
                    Text("No se encontraron resultados.")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray4.edgesIgnoringSafeArea(.all))

    }
    
    // Función para filtrar los resultados según el texto de búsqueda
    func filterResults() {
        if searchText.isEmpty {
            filteredCities = []
            filteredMunicipios = []
        } else {
            filteredCities = Ciudad.allCases.filter { $0.displayName.lowercased().starts(with: searchText.lowercased())}
            filteredMunicipios = Municipio.allCases.filter { $0.displayName.lowercased().starts(with: searchText.lowercased()) }
        }
    }
}

// Extensiones para agregar nombres amigables a las ciudades y municipios
extension Ciudad{
    var displayName: String {
        switch self {
        case .ciudadDeMexico: return "Ciudad de México"
        }
    }
}

extension Municipio{
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
}


#Preview {
    SearchView()
}
