//
//  OnboradingView.swift
//  cambia
//
//  Created by Arantza Castro Dessavre on 10/11/24.
//


import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settings: SelectedMunicipio
    
    @State private var isSearchActive: Bool = false
    @State private var searchText: String = ""
    @State private var filteredMunicipios: [Municipio] = []
    @State private var municipios: [Municipio] = []
    @State private var groupedMunicipiosByState: [(key: String, municipios: [Municipio])] = []
    
    var switchView: () -> Void
    
    var body: some View {
        ZStack {
            Color.gray5.ignoresSafeArea()
            
            VStack {
                header
                    .padding()
                municipiosList
                    .padding(.horizontal)
                exploreButton
            }
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            loadData()
            performSearchOperations()
        }
    }
    
    private var header: some View {
        HStack{
            welcomeText
            
            Spacer()
            
            OnboardingSearchhBarView(isSearchActive: $isSearchActive, searchText: $searchText, filteredMunicipios: $filteredMunicipios)
                .onChange(of: searchText) {
                    performSearchOperations()
                }
        }
    }
    
    private var welcomeText: some View {
        VStack(alignment: .leading, spacing: 10){
            Text("Bienvenido a Cambia")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text("¡Selecciona un municipio y comienza a explorar de inmediato!")
                .font(.title)
                .foregroundStyle(.white)
        }
        .padding()
    }
    
    private var municipiosList: some View {
        VStack{
            if !groupedMunicipiosByState.isEmpty {
                List {
                    ForEach(groupedMunicipiosByState, id: \.0) { (state, municipios) in
                        Section(header: Text(state).font(.headline)) {
                            municipioRows(municipios)
                        }
                        .padding()
                    }
                }
                .background(Color("gray5"))
                .scrollContentBackground(.hidden)
                .padding(.vertical)
            } else {
                Text("No se encontraron resultados.")
            }
        }
    }
    
    private func municipioRows(_ municipios: [Municipio]) -> some View {
        ForEach(municipios, id: \.id) { municipio in
            Button {
                settings.selectedMunicipio = municipio
                searchText = ""
                isSearchActive = false
            } label: {
                HStack {
                    Image(systemName: municipio.displayFullName == settings.selectedMunicipio?.displayFullName ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(municipio.displayFullName == settings.selectedMunicipio?.displayFullName ? .cyan : .white)
                        .padding(.horizontal)
                    Text(municipio.displayFullName)
                        .foregroundStyle(.white)
                }
            }
        }
        .listRowBackground(Color.gray5)
    }
    
    private var exploreButton: some View {
        Button {
            settings.updateMunicipio(newMunicipio: settings.selectedMunicipio!)
            switchView()
        } label: {
            Text("Explorar \(settings.selectedMunicipio?.displayFullName ?? "")")
        }
        .tint(.cyan)
        .padding()
        .disabled(((settings.selectedMunicipio?.displayFullName.isEmpty) == nil))
    }
    
    
    private func performSearchOperations() {
        filterMunicipios()
        groupMunicipiosByState()
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
        let normalizedSearchText = searchText.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        
        filteredMunicipios = municipios.filter { municipio in
            let normalizedDisplayName = municipio.displayFullName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
            return normalizedDisplayName.contains(normalizedSearchText)
        }
    }
    
    private func groupMunicipiosByState() {
        if searchText.isEmpty {
            let grouped = Dictionary(grouping: municipios, by: { $0.estado ?? "Desconocido" })
            groupedMunicipiosByState = grouped.keys.sorted().map { key in (key, grouped[key]!.sorted { ($0.nombre ?? "") < ($1.nombre ?? "") }) }
        } else {
            let grouped = Dictionary(grouping: filteredMunicipios, by: { $0.estado ?? "Desconocido" })
            groupedMunicipiosByState = grouped.keys.sorted().map { key in (key, grouped[key]!.sorted { ($0.nombre ?? "") < ($1.nombre ?? "") }) }
        }
    }
}

struct OnboardingSearchhBarView: View {
    @Binding var isSearchActive: Bool
    @Binding var searchText: String
    @Binding var filteredMunicipios: [Municipio]
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack{
                ZStack {
                    Color.gray6.opacity(0.7)
                        .cornerRadius(20)
                    HStack {
                        TextField("\(Image(systemName: "magnifyingglass"))  Buscar Municipio", text: $searchText)
                            .padding(.horizontal)
                            .foregroundStyle(.white)
                            .preferredColorScheme(.dark)
                        
                        if searchText != "" && !searchText.isEmpty{
                            Button("Cancel") {
                                searchText = ""
                            }
                            .foregroundStyle(Color.teal)
                        }
                    }
                    .padding()
                }
                .frame(width: 300, height: 30)
                .padding()
            }
        }
        .frame(maxHeight: 60)
    }
}

extension SelectedMunicipio {
    func updateMunicipio(newMunicipio: Municipio) {
        selectedMunicipio = newMunicipio
    }
}


#Preview {
    OnboardingView( switchView:{} )
        .environmentObject(SelectedMunicipio())
}