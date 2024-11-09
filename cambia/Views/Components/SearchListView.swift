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
    let maxHeight: CGFloat = 400

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
        }
        .foregroundStyle(.white)
        .background(Color("gray5"))
        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: maxHeight)
        .cornerRadius(20)
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
                Municipio(id: UUID(), nombre: "Aguascalientes", estado: "Aguascalientes"),
                Municipio(id: UUID(), nombre: "Durango", estado: "Durango"),
                Municipio(id: UUID(), nombre: "Tepic", estado: "Nayarit")
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
            Municipio(id: UUID(), nombre: "Oaxaca", estado: "Oaxaca"),
            Municipio(id: UUID(), nombre: "Veracruz", estado: "Veracruz"),
            Municipio(id: UUID(), nombre: "La Paz", estado: "Baja California Sur"),
            Municipio(id: UUID(), nombre: "Querétaro", estado: "Querétaro"),
            Municipio(id: UUID(), nombre: "San Luis Potosí", estado: "San Luis Potosí")
        ])
    )
}
