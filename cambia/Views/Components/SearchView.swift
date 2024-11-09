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
        HStack {
            TextField("Buscar Municipio", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Cancel") {
                isSearching = false
                searchText = ""
            }
            .foregroundStyle(Color.teal)
        }
        .frame(height: 40)
        .padding()
    }
}

#Preview {
    SearchView(isSearching: .constant(true), searchText: .constant("X"))
}
