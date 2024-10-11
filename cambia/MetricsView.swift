//
//  MetricsView.swift
//  cambia
//
//  Created by yatziri on 07/10/24.
//
import SwiftUI
import MapKit

// Our custom view modifier to track rotation and
// call our action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}


/*extension CLLocationCoordinate2D {
    static var start = CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332) // Ciudad de México
}*/


struct MetricsView: View {
    @State private var orientation = UIDeviceOrientation.unknown
    @State private var searchResults: [MKMapItem] = []
    @State private var start = CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332) // Ciudad de México
    @State private var region: MapCameraPosition = .camera(
        .init(centerCoordinate: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), distance: 12000)
        
    )
    @Namespace var mapScope
    @State private var radio:Double = 1
    
    // Variable para guardar el centro del mapa
    @State private var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)

    var body: some View {
        HStack{
            Grid {
                GridRow {
                    VStack {
                        Text("Escuelas")
                            .font(.title3)
                            .bold()
                        Divider()
                        HStack{
                            Text("Escuela mas cercana:")
                                .font(.caption)
                            Spacer()
                            Text("2")
                                .foregroundStyle(Color.orange)
                                .font(.title)
                                .bold()
                            Text("Km")
                                .font(.caption)
                        }
                        Divider()
                        HStack{
                            Text("Tiempo de desplazamiento:")
                                .font(.caption)
                            Spacer()
                            Text("15")
                                .foregroundStyle(Color.orange)
                                .font(.title)
                                .bold()
                            Text("minutos")
                                .font(.caption)
                        }
                        Divider()
                        HStack{
                            Text("No. en un radio de")
                                .font(.caption)
                            /*Picker("\($radio)", selection: $radio) {
                                    ForEach(2..<100) {
                                        Text("\($0)")
                                    }
                            }.pickerStyle(.wheel)
                            */

                            Text("Km")
                                .font(.caption)
                            Spacer()
                            Text("5")
                                .foregroundStyle(Color.orange)
                                .font(.title)
                                .bold()
                        }
                        
                    }
                    .padding()
                    .background(Color.gray6)
                    .cornerRadius(20)
                    .opacity(0.7)
                        
                    
                    Text("R1, C1")
                    Text("R1, C2")
                }
                Text("R1, C1")
                Text("R1, C2")
            }
            MapView()
        }
    }
        
    
    
    func MapView() -> some View {
        ZStack {
          
            Map(position: $region, interactionModes: .all){
                // Anotación inicial
                Annotation("Start", coordinate: start) {
                    Image(systemName: "flag")
                        .padding(4)
                        .foregroundStyle(.white)
                        .background(Color.indigo)
                        .cornerRadius(4)
                }
                
                // Anotaciones de resultados de búsqueda
                ForEach(searchResults, id: \.self) { result in
                    Marker(coordinate: result.placemark.coordinate) {
                        Image(systemName: "mappin")
                            .foregroundColor(.red)
                    }
                }
                
            }
            .onChange(of: region.positionedByUser) {
                
                print("si se ha movido")
                print("region: \(region.positionedByUser), map: \(String(describing: region)), mapScope: \(String(describing: region.rect))")
                //MARK: NO SE PUEDA DETECTAR EL CENTRO
                //start = region.camera!.centerCoordinate
            }
            
            
            VStack {
                HStack {
                    Spacer()
                    
                    VStack {
                        MapPitchToggle(scope: mapScope)
                            .background(Color("gray5"))
                            .cornerRadius(10)
                        MapUserLocationButton(scope: mapScope)
                            .background(Color("gray5"))
                            .cornerRadius(10)
                        
                        ZoomButtonView(zoomIn: true) {
                            zoomIn()
                        }
                        ZoomButtonView(zoomIn: false) {
                            zoomOut()
                        }
                        MapButtonView()
                    }
                    .accentColor(.white)
                    .padding([.bottom, .trailing, .top], 16)
                }
                Spacer()
                MapScaleView(scope: mapScope)
            }
        }
        .mapScope(mapScope)
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
        .labelStyle(.iconOnly)
        .padding([.top, .trailing], 4.0)
    }
    
    // Función para buscar puntos de interés
    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            //center: region.camera?.centerCoordinate ?? ,  // Ahora busca en la región actual
            center: start, span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125)
        )
        
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
        }
    }
    
    // Funciones para el zoom
    func zoomIn() {
            if let currentCamera = region.camera {
                let newDistance = max(currentCamera.distance / 2, 100) // Reduce la distancia para hacer zoom in
                region = .camera(MapCamera(centerCoordinate: currentCamera.centerCoordinate, distance: newDistance))
            }
        }
        
        func zoomOut() {
            if let currentCamera = region.camera {
                let newDistance = min(currentCamera.distance * 2, 20000) // Aumenta la distancia para hacer zoom out
                region = .camera(MapCamera(centerCoordinate: currentCamera.centerCoordinate, distance: newDistance))
            }
        }
}

struct ZoomButtonView: View {
    var zoomIn: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: zoomIn ? "plus" : "minus")
                .frame(width: 44, height: 44)
                .background(Color("gray5"))
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
        .padding(.bottom, 4)
    }
}
#Preview {
    ContentView()
}

#Preview {
    MetricsView()
}
