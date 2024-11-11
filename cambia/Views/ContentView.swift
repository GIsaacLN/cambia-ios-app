//  ContentView.swift
//  cambia

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var metricsViewModel = MetricsViewModel()
    @StateObject private var settings = SelectedMunicipio()
    
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
    @State private var filteredMunicipios: [Municipio] = []
    @State private var municipios: [Municipio] = []

    var body: some View {
        NavigationStack {
            HStack {
                VStack{
                    Text(settings.selectedMunicipio?.displayFullName ?? "Selecciona un Municipio")
                        .padding()
                        .font(.title)
                        .bold()

                    TabView {
                        Tab("Métricas", systemImage: "play") {
                            MetricsView()
                        }
                        Tab("Análisis", systemImage: "books.vertical") {
                            AnalysisView()
                        }
                    }
                    .tabViewStyle(.tabBarOnly)
                    .preferredColorScheme(.dark)
                }
                ZStack (alignment: .top){
                    MapView()
                        .offset(y: 70)
                        .padding(.bottom, 50)
                        .padding()
                        .onAppear {
                            if let municipio = settings.selectedMunicipio {
                                mapViewModel.displayMunicipioGeometry(municipio)
                                mapViewModel.recenter(to: municipio)
                            }
                        }
                        .onChange(of: settings.selectedMunicipio?.clave) {
                            if let municipio = settings.selectedMunicipio {
                                mapViewModel.displayMunicipioGeometry(municipio)
                                mapViewModel.recenter(to: municipio)
                                metricsViewModel.updateMetricsForMunicipio(municipio: municipio)
                            }
                        }
                    
                    SearchBarView(isSearchActive: $isSearchActive, searchText: $searchText,filteredMunicipios: $filteredMunicipios)
                        .onChange(of: searchText) { filterMunicipios() }
                }
            }
            .padding(.horizontal)
            .background(Color.gray5.edgesIgnoringSafeArea(.all))
            .onAppear { loadData() }
            .environmentObject(settings)
            .environmentObject(mapViewModel)
            .environmentObject(metricsViewModel)

        }
    }
    
    private func loadData() {
        guard let url = Bundle.main.url(forResource: "inundacionmunicipio", withExtension: "json") else {
            print("Failed to locate JSON file.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let geoJSON = try JSONDecoder().decode(GeoJSON.self, from: data)
            municipios = geoJSON.features.map { feature in
                let properties = feature.properties
                return Municipio(
                    nombre: properties.nomMun,
                    clave: properties.clv,
                    estado: properties.iviEstad?.capitalized,
                    geometry: feature.geometry,
                    cityArea: properties.areaKm,
                    inundatedArea: properties.areaInun,
                    populationVulnerability: properties.iviPob20,
                    vulnerabilityIndex: properties.iviVulne,
                    floodHazardLevel: properties.peligroIn,
                    threshold12h: properties.umbral12h
                )
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }

    private func filterMunicipios() {
        //Normaliza el texto para eliminar acentos y haciendolo minusculas para mejorar la busqueda
        let normalizedSearchText = searchText.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        
        filteredMunicipios = searchText.isEmpty ? municipios : municipios.filter {
            let normalizedDisplayName = $0.displayFullName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            
            // Checa si el texto normalizado `displayFullName` contiene el texto normalizado de `searchText`
            return normalizedDisplayName.contains(normalizedSearchText)
        }
    }
}

#Preview {
    ContentView()
}
