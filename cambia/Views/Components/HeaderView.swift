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
                    Text(settings.selectedMunicipio?.displayFullName ?? "Selecciona un Municipio")
                    
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
            Municipio(id: UUID(), nombre: "Morelia", estado: "Michoacán"),
            Municipio(id: UUID(), nombre: "Guadalajara", estado: "Jalisco"),
            Municipio(id: UUID(), nombre: "Pátzcuaro", estado: "Michoacán"),
            Municipio(id: UUID(), nombre: "Zamora", estado: "Michoacán"),
            Municipio(id: UUID(), nombre: "Monterrey", estado: "Nuevo León"),
            Municipio(id: UUID(), nombre: "Cancún", estado: "Quintana Roo"),
            Municipio(id: UUID(), nombre: "Tijuana", estado: "Baja California"),
            Municipio(id: UUID(), nombre: "Culiacán", estado: "Sinaloa"),
            Municipio(id: UUID(), nombre: "Toluca", estado: "Estado de México"),
            Municipio(id: UUID(), nombre: "León", estado: "Guanajuato")
        ])
    )
    .environmentObject(SelectedMunicipio())
}

#Preview {
    HeaderView(
        isSearchActive: .constant(false),
        searchText: .constant("Morelia"),
        filteredMunicipios: .constant([
            Municipio(id: UUID(), nombre: "Morelia", estado: "Michoacán"),
            Municipio(id: UUID(), nombre: "Guadalajara", estado: "Jalisco"),
            Municipio(id: UUID(), nombre: "Pátzcuaro", estado: "Michoacán"),
            Municipio(id: UUID(), nombre: "Zamora", estado: "Michoacán"),
            Municipio(id: UUID(), nombre: "Monterrey", estado: "Nuevo León"),
            Municipio(id: UUID(), nombre: "Cancún", estado: "Quintana Roo"),
            Municipio(id: UUID(), nombre: "Tijuana", estado: "Baja California"),
            Municipio(id: UUID(), nombre: "Culiacán", estado: "Sinaloa"),
            Municipio(id: UUID(), nombre: "Toluca", estado: "Estado de México"),
            Municipio(id: UUID(), nombre: "León", estado: "Guanajuato")
        ])
    )
    .environmentObject(SelectedMunicipio())
}
