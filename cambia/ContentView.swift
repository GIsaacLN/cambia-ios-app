//
//  ContentView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 07/10/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    var body: some View {
        TabView {
            Tab("Metricas", systemImage: "play") {
                MetricsView()
            }
            Tab("Simulación", systemImage: "books.vertical") {
                //LibraryView()
            }
            Tab("Reportes", systemImage: "play") {
                //WatchNowView()
            }
            Tab("Ajustes", systemImage: "books.vertical") {
                //LibraryView()
            }
            Tab(role: .search) {
//                SearchView()
            }

        }.tabViewStyle(.sidebarAdaptable)
            .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
