//
//  HeaderView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 09/11/24.
//

import SwiftUI

struct HeaderView: View {
    @Binding var isSearchActive: Bool
    @Binding var searchText: String
    @Binding var filteredMunicipios: [Municipio]
    @EnvironmentObject var settings: SelectedMunicipio

    var body: some View {
        VStack(alignment: .leading) {
            ZStack{
                HStack {
                    Text("\(settings.selectedMunicipio?.displayName ?? "No se seleccionó un municipio"), \(settings.selectedMunicipio?.estado ?? "")")
                    
                    if isSearchActive {
                        SearchView(isSearching: $isSearchActive, searchText: $searchText)
                    } else {
                        Button {
                            isSearchActive = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.teal)
                        }
                    }
                }
                .padding()
                
                // Display SearchListView as a popup below the search bar when active
                if isSearchActive {
                    SearchListView(
                        isSearching: $isSearchActive,
                        searchText: $searchText,
                        filteredMunicipios: $filteredMunicipios
                    )
                    .frame(height: 300)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    .transition(.move(edge: .top))
                    .offset(y:170)
                }
            }
        }
        .frame(maxWidth: 500, maxHeight: 60)
    }
}

#Preview {
    HeaderView(
        isSearchActive: .constant(true),
        searchText: .constant("Morelia"),
        filteredMunicipios: .constant([
            Municipio(id: UUID(), displayName: "Morelia", estado: "Michoacán"),
            Municipio(id: UUID(), displayName: "Guadalajara", estado: "Jalisco"),
            Municipio(id: UUID(), displayName: "Pátzcuaro", estado: "Michoacán"),
            Municipio(id: UUID(), displayName: "Zamora", estado: "Michoacán"),
            Municipio(id: UUID(), displayName: "Monterrey", estado: "Nuevo León"),
            Municipio(id: UUID(), displayName: "Cancún", estado: "Quintana Roo"),
            Municipio(id: UUID(), displayName: "Tijuana", estado: "Baja California"),
            Municipio(id: UUID(), displayName: "Culiacán", estado: "Sinaloa"),
            Municipio(id: UUID(), displayName: "Toluca", estado: "Estado de México"),
            Municipio(id: UUID(), displayName: "León", estado: "Guanajuato")
        ])
    )
    .environmentObject(SelectedMunicipio())
}

#Preview {
    HeaderView(
        isSearchActive: .constant(false),
        searchText: .constant("Morelia"),
        filteredMunicipios: .constant([
            Municipio(id: UUID(), displayName: "Morelia", estado: "Michoacán"),
            Municipio(id: UUID(), displayName: "Guadalajara", estado: "Jalisco"),
            Municipio(id: UUID(), displayName: "Pátzcuaro", estado: "Michoacán"),
            Municipio(id: UUID(), displayName: "Zamora", estado: "Michoacán"),
            Municipio(id: UUID(), displayName: "Monterrey", estado: "Nuevo León"),
            Municipio(id: UUID(), displayName: "Cancún", estado: "Quintana Roo"),
            Municipio(id: UUID(), displayName: "Tijuana", estado: "Baja California"),
            Municipio(id: UUID(), displayName: "Culiacán", estado: "Sinaloa"),
            Municipio(id: UUID(), displayName: "Toluca", estado: "Estado de México"),
            Municipio(id: UUID(), displayName: "León", estado: "Guanajuato")
        ])
    )
    .environmentObject(SelectedMunicipio())
}
