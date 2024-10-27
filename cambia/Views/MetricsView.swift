//
//  MetricsView.swift
//  cambia
//
//  Created by yatziri on 07/10/24.
//

import SwiftUI

struct MetricsView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var metricsViewModel: MetricsViewModel
    
   /* @State private var selectedCity: Ciudad = .ciudadDeMexico
    @State private var selectedMunicipio: Municipio = .azcapotzalco*/
    
    @State private var inegiData: InegiData? = nil
    
    @State private var isLoading = false
    
    @ObservedObject var errorDelegate = InegiDataDelegate()
    
    @EnvironmentObject var viewModel : CiudadMunicipioViewModel
    
    
    // Definimos el formateador de números
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","
        return formatter
    }
    
    init() {
        let mapVM = MapViewModel()
        _mapViewModel = StateObject(wrappedValue: mapVM)
        _metricsViewModel = StateObject(wrappedValue: MetricsViewModel(mapViewModel: mapVM))
    }
    
    //MARK: MetricsView body
    var body: some View {
        NavigationStack {
            VStack{
                Text("\(viewModel.selectedCiudadMunicipio)")
                HStack {
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
                            
                            
                            Text("R1")
                            Text("R1")
                        }
                        if isLoading{
                            ProgressView()
                        }else{
                            // Mostrar los resultados de los indicadores
                            Button(action: loadData) {
                                Text("Cargar Datos")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            if let data = inegiData {
                                Text("Resultados para \(data.city), \(data.municipio):")
                                    .font(.headline)
                                ForEach(data.indicators.sorted(by: >), id: \.key) { key, value in
                                    if let formattedValue = formatter.string(from: NSNumber(value: value)) {
                                        Text("\(key): \(formattedValue)")
                                    }
                                }
                            }
                        }
                    }
                    
                    MapView(viewModel: mapViewModel)
                }
            }
        }
        .onAppear() {
            loadData()
        }
        
    }
    
    //MARK: FUNC:InegiDataManager
    // Función para cargar los datos usando `InegiDataManager`
    func loadData() {
        isLoading = true
        DispatchQueue.global(qos:.background).async {
            
            let manager = InegiDataManager()
            manager.delegate = errorDelegate
            // Solicita los indicadores de población y densidad
            let indicators = [IndicatorType.poblacionTotal.rawValue, IndicatorType.dencidad.rawValue]
            
            manager.fetchData(indicators: indicators, ciudad:viewModel.selectedCiudadMunicipio.ciudad.rawValue, municipio: viewModel.selectedCiudadMunicipio.municipios?.rawValue) { data in
                if let dat = data {
                    DispatchQueue.main.async {
                        isLoading = false
                        self.inegiData = dat
                    }
                    
                }
            }
        }
    }
}
#Preview {
    MetricsView().preferredColorScheme(.dark)
}
