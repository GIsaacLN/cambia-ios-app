//  ContentView.swift
//  cambia

import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var viewModel: EstadoMunicipioViewModel
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var metricsViewModel: MetricsViewModel
    
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
    @State private var filteredCities: [Estado] = []
    @State private var filteredMunicipios: [Municipio] = []
    
    init(estadoMunicipioViewModel: EstadoMunicipioViewModel) {
        let mapVM = MapViewModel()
        _mapViewModel = StateObject(wrappedValue: mapVM)
        _metricsViewModel = StateObject(wrappedValue: MetricsViewModel(mapViewModel: mapVM, estadoMunicipioViewModel: estadoMunicipioViewModel))
    }

    var body: some View {
        NavigationStack {
            
            TabView {
                // Pestaña de Métricas
                Tab("Métricas", systemImage: "play") {
                    ZStack {
                        MetricsView(estadoMunicipioViewModel: viewModel)
                        if isSearchActive {
                            VStack {
                                HStack {
                                    Spacer()
                                    SearchListView(
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
            .navigationTitle(viewModel.textSelectedEstadoMunicipio(for: viewModel.selectedEstadoMunicipio.estado, to: viewModel.selectedEstadoMunicipio.municipios))
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
            filteredCities = Estado.allCases.filter { $0.displayName.lowercased().starts(with: searchText.lowercased()) }
            filteredMunicipios = Municipio.allCases.filter { $0.displayName.lowercased().starts(with: searchText.lowercased()) }
        }
    }
}
