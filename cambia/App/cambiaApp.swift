//
//  cambiaApp.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 07/10/24.
//

import SwiftUI

@main
struct cambiaApp: App {
    
    var viewModel = EstadoMunicipioViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(estadoMunicipioViewModel: viewModel)
                .environmentObject(viewModel)
        }
    }
}
