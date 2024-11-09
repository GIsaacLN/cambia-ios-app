//
//  SearchView.swift
//  cambia
//
//  Created by yatziri on 26/10/24.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @Binding var isSearching: Bool
    @Binding var searchText: String
    
    var body: some View {
        ZStack {
            Color.gray6.opacity(0.7)
                .cornerRadius(20)
            TextField("\(Image(systemName: "magnifyingglass"))  Buscar Ciudad o Municipio", text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 7.5)
        }
        .padding()
    }
}

#Preview{
    SearchView(isSearching: .constant(true), searchText: .constant("X"))
}
