//
//  SearchListView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 08/11/24.
//

import SwiftUI

// SearchListView.swift (for displaying search results as a dropdown)
struct SearchListView: View {
    @EnvironmentObject var settings: SelectedMunicipio
    @Binding var isSearching: Bool
    @Binding var searchText: String
    @Binding var filteredMunicipios: [Municipio]
    let maxHeight: CGFloat = 600
    let itemHeight: CGFloat = 50 // estimated height of each item

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                if !filteredMunicipios.isEmpty {
                    Section(header: Text("Municipios Encontrados").font(.headline)) {
                        ForEach(filteredMunicipios) { municipio in
                            Button {
                                settings.selectedMunicipio = municipio
                                searchText = ""
                                isSearching = false
                                filteredMunicipios = []
                            } label: {
                                HStack {
                                    Text(municipio.displayFullName)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                } else if !searchText.isEmpty {
                    Text("No se encontraron resultados.")
                        .padding()
                }
            }
            .padding()
        }
        .foregroundStyle(.white)
        .background(Color("gray5"))
        .frame(
            maxWidth: .infinity,
            minHeight: 80,
            maxHeight: 300
        )
        .cornerRadius(10)
        .padding(.vertical)
    }
}

#Preview {
    VStack {
        SearchListView(
            isSearching: .constant(true),
            searchText: .constant("P"),
            filteredMunicipios: .constant([])
        )

        SearchListView(
            isSearching: .constant(true),
            searchText: .constant(""),
            filteredMunicipios: .constant([
                Municipio(nombre: "Aguascalientes", estado: "Aguascalientes"),
                Municipio(nombre: "Durango", estado: "Durango"),
                Municipio(nombre: "Tepic", estado: "Nayarit")
            ])
        )
    }
    .padding()
}

#Preview {
    SearchListView(
        isSearching: .constant(true),
        searchText: .constant(""),
        filteredMunicipios: .constant([
            Municipio(nombre: "Oaxaca", estado: "Oaxaca"),
            Municipio(nombre: "Veracruz", estado: "Veracruz"),
            Municipio(nombre: "La Paz", estado: "Baja California Sur"),
            Municipio(nombre: "Querétaro", estado: "Querétaro"),
            Municipio(nombre: "San Luis Potosí", estado: "San Luis Potosí")
        ])
    )
}
