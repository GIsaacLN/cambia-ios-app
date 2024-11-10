//  ContentView.swift
//  cambia

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var metricsViewModel: MetricsViewModel
    @StateObject private var settings = SelectedMunicipio()
    
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
    @State private var filteredMunicipios: [Municipio] = []
    @State private var municipios: [Municipio] = []

    init() {
        let mapVM = MapViewModel()
        _mapViewModel = StateObject(wrappedValue: mapVM)
        _metricsViewModel = StateObject(wrappedValue: MetricsViewModel(mapViewModel: mapVM))
    }

    var body: some View {
        NavigationStack {
            HStack {
                ZStack (alignment: .top){
                    TabView {
                        Tab("Métricas", systemImage: "play") {
                            MetricsView()
                        }
                        Tab("Análisis", systemImage: "books.vertical") {
                            AnalysisView(metricsViewModel: metricsViewModel)
                        }
                        Tab("Fixdata", systemImage: "play") {
                            Text("Placeholder content")
                        }
                    }
                    .tabViewStyle(.tabBarOnly)
                    .preferredColorScheme(.dark)
                    .offset(y: 70)
                    
                    HeaderView(
                        isSearchActive: $isSearchActive,
                        searchText: $searchText,
                        filteredMunicipios: $filteredMunicipios
                    )
                    .onChange(of: searchText) { filterMunicipios() }
                }
                MapView(viewModel: mapViewModel)
                    .padding()
            }
            .padding(.horizontal)
            .background(Color.gray5.edgesIgnoringSafeArea(.all))
            .onAppear { loadData() }
            .environmentObject(settings)
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
            municipios = geoJSON.features.map { Municipio(
                id: UUID(),
                displayName: $0.properties.nomMun,
                clave: $0.properties.clv,
                estado: $0.properties.iviEstad?.capitalized
            )}
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }

    private func filterMunicipios() {
        filteredMunicipios = searchText.isEmpty ? municipios : municipios.filter {
            $0.displayName?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
}

#Preview {
    ContentView()
}
