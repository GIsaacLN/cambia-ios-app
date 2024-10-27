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
                    //MARK: Error
                    //no se pasa viewModel: viewModel
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
                    //SearchView(viewModel: viewModel)
                }
                
            }.tabViewStyle(.tabBarOnly)
                .preferredColorScheme(.dark)
                .navigationTitle(            viewModel.textselectedCiudadMunicipio(for: viewModel.selectedCiudadMunicipio.ciudad, to: viewModel.selectedCiudadMunicipio.municipios))
                .navigationBarTitleDisplayMode(.inline)
        }
       // .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
