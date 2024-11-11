//
//  HeaderView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 09/11/24.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var isSearchActive: Bool
    @Binding var searchText: String
    @Binding var filteredMunicipios: [Municipio]
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack{
                SearchView(isSearching: $isSearchActive, searchText: $searchText)
                    .padding()
                
                // Display SearchListView as a popup below the search bar when active
                if searchText != "" && !searchText.isEmpty {
                    SearchListView(
                        isSearching: $isSearchActive,
                        searchText: $searchText,
                        filteredMunicipios: $filteredMunicipios
                    )
                    .frame(height: 300)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 30)
                    .transition(.move(edge: .top))
                    .offset(y:200)
                }
            }
        }
        .frame(maxHeight: 60)
    }
}

#Preview {
    SearchBarView(
        isSearchActive: .constant(true),
        searchText: .constant("Morelia"),
        filteredMunicipios: .constant([
            Municipio(nombre: "Morelia", estado: "Michoacán"),
            Municipio(nombre: "Guadalajara", estado: "Jalisco"),
            Municipio(nombre: "Pátzcuaro", estado: "Michoacán"),
            Municipio(nombre: "Zamora", estado: "Michoacán"),
            Municipio(nombre: "Monterrey", estado: "Nuevo León"),
            Municipio(nombre: "Cancún", estado: "Quintana Roo"),
            Municipio(nombre: "Tijuana", estado: "Baja California"),
            Municipio(nombre: "Culiacán", estado: "Sinaloa"),
            Municipio(nombre: "Toluca", estado: "Estado de México"),
            Municipio(nombre: "León", estado: "Guanajuato")
        ])
    )
}

#Preview {
    SearchBarView(
        isSearchActive: .constant(true),
        searchText: .constant("a"),
        filteredMunicipios: .constant([
            Municipio(nombre: "Morelia", estado: "Michoacán"),
            Municipio(nombre: "Guadalajara", estado: "Jalisco")
        ])
    )
}

#Preview {
    SearchBarView(
        isSearchActive: .constant(true),
        searchText: .constant("a"),
        filteredMunicipios: .constant([])
    )
}
