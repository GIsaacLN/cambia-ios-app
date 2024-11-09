//  ContentView.swift
//  cambia

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var metricsViewModel: MetricsViewModel
    @StateObject var selectedMunicipio = SelectedMunicipio()

    
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
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
                                    SearchListView(
                                        isSearching: $isSearchActive,
                                        searchText: $searchText,
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
// MARK: - FIX This later
//            .navigationTitle(viewModel.textSelectedEstadoMunicipio(for: viewModel.selectedEstadoMunicipio.estado, to: viewModel.selectedEstadoMunicipio.municipios))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isSearchActive {
                    SearchView(isSearching: $isSearchActive, searchText: $searchText)
                        .onChange(of: searchText) { _ in
                            filterMunicipios()
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
            .onAppear {
                loadData()
            }
        }
        .environmentObject(selectedMunicipio)
    }
    
    private func loadData() {
        guard let url = Bundle.main.url(forResource: "inundacionmunicipio", withExtension: "json") else {
            print("Failed to locate JSON file.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let geoJSON = try JSONDecoder().decode(GeoJSON.self, from: data)
            
            // Map features to Municipios
            filteredMunicipios = geoJSON.features.map { feature in
                Municipio(
                    id: UUID(),
                    displayName: feature.properties.nomMun,
                    clave: feature.properties.cveMpio
                )
            }
            
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }

    private func filterMunicipios() {
        if searchText.isEmpty {
            // Show all if search is empty
            filteredMunicipios = filteredMunicipios
        } else {
            filteredMunicipios = filteredMunicipios.filter { municipio in
                municipio.displayName?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
}
