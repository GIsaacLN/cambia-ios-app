//
//  ContentView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 07/10/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var viewModel: CiudadMunicipioViewModel
   
    var body: some View {
        NavigationStack{
            TabView {
                Tab("Metricas", systemImage: "play") {
                    MetricsView()
                }
                Tab("Analisis", systemImage: "books.vertical") {
                    //LibraryView()
                }
                Tab("Fixdata", systemImage: "play") {
                    //WatchNowView()
                }
                /*Tab("Ajustes", systemImage: "books.vertical") {
                 //LibraryView()
                 }*/
                Tab(role: .search) {
                    SearchView()
                }
                
            }.tabViewStyle(.tabBarOnly)
                .preferredColorScheme(.dark)
                .navigationTitle(            viewModel.textselectedCiudadMunicipio(for: viewModel.selectedCiudadMunicipio.ciudad, to: viewModel.selectedCiudadMunicipio.municipios))
                .navigationBarTitleDisplayMode(.inline)
                
        }.background(Color.gray4.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    ContentView()
}
