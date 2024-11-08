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
    @Binding var filteredCities: [Estado]
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
