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
            HStack{
                //Text("\(viewModel.selectedCiudadMunicipio)")
                VStack {
                    Grid {
                        GridRow {
                            DISTRIBUCIONDEVIVIENDAS()
                            Grid{
                                GridRow{
                                    DENSIDADPOBLACIONAL()
                                    POBLACIONTOTAL()
                                }
                                PORCENTAJEPOBREZA()
                                
                            }
                            
                        }
                        /*if isLoading{
                            ProgressView()
                        }else{
                            DatosDemográficosSociales()
                        }*/
                    }
                    .padding()
                    Spacer()
                }
                MapView(viewModel: mapViewModel)
                    .padding()
                
            }
            .background(Color.gray4.edgesIgnoringSafeArea(.all))

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
            let indicators = [ IndicatorType.viviendasConAgua.rawValue, IndicatorType.viviendasConElectricidad.rawValue,IndicatorType.poblacionTotal.rawValue, IndicatorType.dencidad.rawValue]
            
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
    
    //MARK: FUNC:DENSIDAD
    func DENSIDADPOBLACIONAL() -> some View {
        VStack {
            Text("DENSIDAD POBLACIONAL")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
                .lineLimit(1)
                .padding(.horizontal)
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                VStack{
                    HStack {
                        if isLoading{
                            ProgressView()
                        }else{
                            if let data = inegiData,
                               let densityValue = data.indicators["dencidad"],
                               let formattedValue = formatter.string(from: NSNumber(value: densityValue)) {
                                Text(formattedValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                    }.padding([.top, .leading, .trailing])
                        .padding(.bottom, 5.0)
                    HStack{
                        Image(systemName: "person.3.sequence.fill")
                            .foregroundStyle(.teal)
                        Spacer()
                        Text("Hab/Km²")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }.padding([.leading, .trailing])
                }
            }.frame(width: 140, height: 90)
        }
    }
    
    
    //MARK: FUNC:POBLACIÓN
    func POBLACIONTOTAL() -> some View {
        VStack {
            Text("POBLACIÓN TOTAL")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
                .lineLimit(1)
//                .padding(.horizontal)
                
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                VStack{
                    HStack {
                        if isLoading{
                            ProgressView()
                        }else{
                            if let data = inegiData,
                               let densityValue = data.indicators["poblacionTotal"],
                               let formattedValue = formatter.string(from: NSNumber(value: densityValue)) {
                                Text(formattedValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }}
                    }.padding([.top, .leading, .trailing])
                        .padding(.bottom, 5.0)
                    HStack{
                        Image(systemName: "figure")
                            .foregroundStyle(.teal)
                            .bold()
                        Spacer()
                        Text("Personas")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }.padding([.leading, .trailing])
                }
            }.frame(width: 140, height: 90)
        }
    }
    
    //MARK: FUNC:POBLACIÓN
    func DISTRIBUCIONDEVIVIENDAS() -> some View {
        VStack {
            Text("DISTRIBUCIÓN DE VIVIENDAS")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
                .lineLimit(1)
                
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                VStack{
                    HStack{
                        Image(systemName: "percent")
                            .foregroundStyle(.teal)
                            .bold()
                        Text("Porcentajes")
                            .font(.title3)
                            .bold()
                        
                    }.padding(5.0)
                    Divider()
                    HStack {
                        Text("Viviendas con electricidad")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Spacer()
                        if isLoading{
                            ProgressView()
                        }else{
                            if let data = inegiData,
                               let densityValue = data.indicators["viviendasConElectricidad"],
                               let formattedValue = formatter.string(from: NSNumber(value: densityValue)) {
                                Text(formattedValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                        Text("%")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }.padding([.top, .leading, .trailing])
                        .padding(.bottom, 5.0)
                    HStack {
                        Text("Viviendas con agua entubada")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Spacer()
                        if isLoading{
                            ProgressView()
                        }else{
                            if let data = inegiData,
                               let densityValue = data.indicators["viviendasConAgua"],
                               let formattedValue = formatter.string(from: NSNumber(value: densityValue)) {
                                Text(formattedValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                        Text("%")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }.padding([.top, .leading, .trailing])
                        .padding(.bottom, 5.0)
                    
                }
            }.frame(width: 200, height: 160)
        }
    }
    
    func DatosDemográficosSociales() -> some View {
        VStack {
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
                Text("\(data.indicators.count)")
                ForEach(data.indicators.sorted(by: >), id: \.key) { key, value in
                    if let formattedValue = formatter.string(from: NSNumber(value: value)) {
                        Text("\(key): \(formattedValue)")
                    }
                }
            }
        }
    }
    
    //MARK: ‼️FUNC:POBLACIÓN
    func PORCENTAJEPOBREZA() -> some View {
        VStack {
            Text("PORCENTAJE")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
                .lineLimit(1)
//                .padding(.horizontal)
                
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                    HStack {
                        Text("Pobreza")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(.leading, 3.0)
                        Spacer()
                        Image(systemName: "percent")
                            .foregroundStyle(.teal)
                            .bold()
                        if isLoading{
                            ProgressView()
                        }else{
                            Text("85.42")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            /*if let data = inegiData,
                               let densityValue = data.indicators["viviendasConElectricidad"],
                               let formattedValue = formatter.string(from: NSNumber(value: densityValue)) {
                                Text(formattedValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }*/
                        }
                        
                    }.padding(3.0)
                    
                
            }.frame(width: 140, height: 50)
        }
    }
}
#Preview {
    MetricsView().preferredColorScheme(.dark)
}


