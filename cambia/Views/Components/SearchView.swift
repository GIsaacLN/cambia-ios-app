//
//  SearchView.swift
//  cambia
//
//  Created by yatziri on 26/10/24.
//

import SwiftUI

struct SearchView: View {
    @Binding var isSearching: Bool
    @Binding var searchText: String
    
    var body: some View {
        ZStack {
            Color.gray6.opacity(0.7)
                .cornerRadius(10)
            HStack {
                TextField("\(Image(systemName: "magnifyingglass"))  Buscar Municipio", text: $searchText)
                    .padding(.horizontal)
                    .foregroundStyle(.white)
                    .preferredColorScheme(.dark)
                    .accessibilityLabel("Buscar municipio")
                    .accessibilityHint("Escribe para filtrar la lista de municipios")
                
                if searchText != "" && !searchText.isEmpty{
                    Button("Cancelar") {
                        searchText = ""
                    }
                    .foregroundStyle(Color.teal)
                    .accessibilityLabel("Cancelar búsqueda")
                }
            }
            .padding()
        }
        .frame(height: 40)
    }
}

#Preview {
    SearchView(isSearching: .constant(true), searchText: .constant("X"))
}

#Preview {
    SearchView(isSearching: .constant(false), searchText: .constant(""))
}
