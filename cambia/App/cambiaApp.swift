//
//  cambiaApp.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 07/10/24.
//

import SwiftUI

@main
struct cambiaApp: App {
    @State private var viewIndex: Int = 0
    @StateObject var settings = SelectedMunicipio()  // Shared instance
    
    var body: some Scene {
        WindowGroup {
            if viewIndex == 0 {
                OnboardingView(switchView: switchView)
            } else {
                ContentView()
            }
        }
        .environmentObject(settings)
    }
    
    func switchView() {
        withAnimation {
            viewIndex = (viewIndex == 0 ? 1 : 0)  // Toggle between 0 and 1
        }
    }
}
