//
//  ContentView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 07/10/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var viewModel: CiudadMunicipioViewModel
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
    @State private var filteredCities: [Ciudad] = []
    @State private var filteredMunicipios: [Municipio] = []
    
    var body: some View {
        NavigationStack {
            
            TabView {
                Tab("Metricas", systemImage: "play") {
                    ZStack{
                        MetricsView()
                        if isSearchActive {
                            VStack{
                                HStack{
                                    Spacer()
                                    SearchlistView(
                                        isSearching: $isSearchActive,
                                        searchText: $searchText,
                                        filteredCities: $filteredCities,
                                        filteredMunicipios: $filteredMunicipios).frame(width: 400)
                                        .padding()
                                        .padding(.top)
                                        .ignoresSafeArea()
                                        
                                    
                                }
                                Spacer()
                            }
                        }
                    }
                }
                Tab("Analisis", systemImage: "books.vertical") {
                    //LibraryView()
                }
                Tab("Fixdata", systemImage: "play") {
                    //WatchNowView()
                }
            }
            .tabViewStyle(.tabBarOnly)
            .preferredColorScheme(.dark)
            .navigationTitle(viewModel.textselectedCiudadMunicipio(for: viewModel.selectedCiudadMunicipio.ciudad, to: viewModel.selectedCiudadMunicipio.municipios))
            .navigationBarTitleDisplayMode(.inline)
            
            // Mostrar SearchlistView sobre TabView cuando isSearchActive está activo
            
            
            .toolbar {
                
                    if isSearchActive {
                        SearchView(isSearching: $isSearchActive, searchText: $searchText)
                            .onChange(of: searchText) { _ in
                                filterResults() 
                            }
                            .padding(.top)
                        Button("Cancel") {
                            isSearchActive = false
                            searchText = ""
                        }
                        .foregroundStyle(Color.teal)
                                            
                    } else {
                        Button {
                            isSearchActive = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.teal)
                        }
                    }
                }
            
        }
    }
    
    // Función para filtrar los resultados según el texto de búsqueda
    func filterResults() {
            if searchText.isEmpty {
                filteredCities = []
                filteredMunicipios = []
            } else {
                filteredCities = Ciudad.allCases.filter { $0.displayName.lowercased().starts(with: searchText.lowercased()) }
                filteredMunicipios = Municipio.allCases.filter { $0.displayName.lowercased().starts(with: searchText.lowercased()) }
            }
        }
}

#Preview {
    ContentView()
}
