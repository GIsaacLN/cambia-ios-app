//
//  MetricsView.swift
//  cambia
//
//  Created by yatziri on 07/10/24.
//

import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static var start = CLLocationCoordinate2D(latitude: 49.7071, longitude: 0.2064)
}

struct MetricsView: View {
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View {
        VStack  {
            Text("hola")
            MapView()
        }
    }
    func MapView() -> some View {
        Map {
            Annotation("Start",
                       coordinate: .start,
                       anchor: .bottom
            ){
                Image(systemName: "flag")
                    .padding(4)
                    .foregroundStyle(.white)
                    .background(Color.indigo)
                    .cornerRadius(4)
            }
            
            ForEach(searchResults, id: \.self) { result in
                Marker(item: result)
            }
            .annotationTitles(.hidden)
        }
        .mapControls {
            MapPitchToggle()
                .padding()
            MapUserLocationButton()
                .padding()
            MapCompass()
            MapScaleView()
            HStack (){
                Spacer()
                MapButtonView()
            }
        }.accentColor(.white)
            
           
        .safeAreaInset(edge: .top) {
            HStack (){
                Spacer()
                MapButtonView()
            }
        }
        //.background(.thinMaterial)
        //.mapStyle(.standard(elevation: .realistic))
    }
    
    func MapButtonView() -> some View {
        HStack {
            Button {
                search(for: "Hospital")
            } label: {
                Label ("Cafes", systemImage: "square.stack.3d.up.fill")
                    .frame(width: 44, height: 44)
            }
            .background(Color("gray5"))
            .foregroundStyle(.white)
            .cornerRadius(10)
            
        }
        .labelStyle (.iconOnly)
        .padding([.top, .trailing], 4.0)
    }
    
   
    
    
    func search(for query: String) {
        let request = MKLocalSearch.Request ()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region =  MKCoordinateRegion (
            center: .start,
            span: MKCoordinateSpan (latitudeDelta: 0.0125, longitudeDelta: 0.0125))
        
        Task {
            let search = MKLocalSearch (request: request)
            let response = try? await search.start ()
            searchResults = response?.mapItems ?? []
        }
    }
}
#Preview {
    ContentView()
}
#Preview {
    MetricsView()
}
