//  ContentView.swift
//  cambia

import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var viewModel: CiudadMunicipioViewModel
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var metricsViewModel: MetricsViewModel
    
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
    @State private var filteredCities: [Ciudad] = []
    @State private var filteredMunicipios: [Municipio] = []
    
    init() {
        let mapVM = MapViewModel()
        _mapViewModel = StateObject(wrappedValue: mapVM)
        _metricsViewModel = StateObject(wrappedValue: MetricsViewModel(mapViewModel: mapVM))
    }

    var body: some View {
        NavigationStack {
            
            TabView {
                // Pestaña de Métricas
                Tab("Métricas", systemImage: "play") {
                    ZStack {
                        MetricsView()
                        if isSearchActive {
                            VStack {
                                HStack {
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
                
                // Nueva pestaña de Análisis con AnalysisView integrada
                Tab("Análisis", systemImage: "books.vertical") {
                    AnalysisView(metricsViewModel: metricsViewModel) // Pasamos metricsViewModel como argumento
                }
                
                // Otra pestaña (placeholder)
                Tab("Fixdata", systemImage: "play") {
                    // Aquí puedes añadir la vista correspondiente a "Fixdata"
                }
            }
            .tabViewStyle(.tabBarOnly)
            .preferredColorScheme(.dark)
            .navigationTitle(viewModel.textselectedCiudadMunicipio(for: viewModel.selectedCiudadMunicipio.ciudad, to: viewModel.selectedCiudadMunicipio.municipios))
            .navigationBarTitleDisplayMode(.inline)
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
