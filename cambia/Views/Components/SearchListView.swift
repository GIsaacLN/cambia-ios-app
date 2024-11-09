//
//  SearchListView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 08/11/24.
//

import SwiftUI

// SearchListView para mostrar los resultados de búsqueda
struct SearchListView: View {
    @EnvironmentObject var settings: SelectedMunicipio
    @Binding var isSearching: Bool
    @Binding var searchText: String
    @Binding var filteredMunicipios: [Municipio]
    let maxHeight: CGFloat = 400 // Maximum height for the list

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
                                    Text("\(municipio.displayName ?? ""), \(municipio.estado ?? "")")
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
            
            if filteredMunicipios.isEmpty && !searchText.isEmpty {
                Text("No se encontraron resultados.")
                    .padding()
            }
        }
        .foregroundStyle(.white)
        .background(Color("gray5"))
        .frame(minHeight: 100, maxHeight: maxHeight) // Restricting height for scroll view
        .cornerRadius(20)
        .padding(.vertical)
    }
}

#Preview {
    VStack {
        SearchListView(isSearching: .constant(true), searchText: .constant("H"), filteredMunicipios: .constant([]))

        SearchListView(
            isSearching: .constant(true),
            searchText: .constant(""),
            filteredMunicipios: .constant([
                Municipio(id: UUID(), displayName: "Aca", estado: "Example State")
            ])
        )
    }
    .padding()
}

#Preview {
    SearchListView(isSearching: .constant(true), searchText: .constant("H"), filteredMunicipios: .constant([]))
}

#Preview {
    SearchListView(isSearching: .constant(true), searchText: .constant(""), filteredMunicipios: .constant([Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca"),Municipio(id: UUID.init(),displayName: "Aca")]))
}
