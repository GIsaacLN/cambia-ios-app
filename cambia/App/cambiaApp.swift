//
//  cambiaApp.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 07/10/24.
//

import SwiftUI

@main
struct cambiaApp: App {
    
    var viewModel = CiudadMunicipioViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
        
    }
}
