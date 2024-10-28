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
                    VStack (alignment:.center){
                        HStack(alignment:.top) {
                            DISTRIBUCIONDEVIVIENDAS()
                            VStack(alignment: .center){
                                HStack(alignment:.top){
                                    DENSIDADPOBLACIONAL()
                                    POBLACIONTOTAL()
                                }
                                HStack(alignment:.center){
                                    PORCENTAJEPOBREZA()
                                        .padding(.trailing, 5.0)
                                    PORCENTAJEinundada()
                                        .padding(.leading, 10.0)
                                }
                            }
                            
                        }
                        HStack (alignment: .top){
                            SERVICIOSBASICOS()
                            VStack(alignment:.center){
                                SUPERFICIEDELACIUDAD()
                                AREAINUNDADA()
                            }
                        }
                        HStack (alignment: .top){
                            PRECIPITACIONES()
                            PELIGRODEINUNDACION()
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
                    Divider()
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
                    .cornerRadius(15)
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
                                .font(.callout)
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
    
    //MARK: ‼️FUNC:POBLACIÓN
    func PORCENTAJEinundada() -> some View {
        VStack{
            Text("PORCENTAJE")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
                .lineLimit(1)
                
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(15)
                    HStack{
                        Text("Área inundada")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            
//                            .padding(.leading, 3.0)
                            
                        Spacer()
                        Image(systemName: "percent")
                            .foregroundStyle(.teal)
                            .bold()
                        if isLoading{
                            ProgressView()
                        }else{
                            Text("85.42")
                                .font(.callout)
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
    
    //MARK: ‼️FUNC:ÁREA INUNDADA
    func AREAINUNDADA() -> some View {
        VStack {
            Text("ÁREA INUNDADA")
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
                            Text("5,200.00")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                        }
                    }.padding([.top, .leading, .trailing])
                        .padding(.bottom, 5.0)
                    HStack{
                        Image(systemName: "water.waves")
                            .foregroundStyle(.teal)
                            .bold()
                        Spacer()
                        
                        Text("Km²")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }.padding([.leading, .trailing])
                }
            }.frame(width: 140, height: 90)
        }
    }
    
    //MARK: ‼️FUNC:SUPERFICIE DE LA CIUDAD
    func SUPERFICIEDELACIUDAD() -> some View {
        VStack {
            Text("SUPERFICIE DE LA CIUDAD")
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
                            Text("100,000.00")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                        }
                    }.padding([.top, .leading, .trailing])
                        .padding(.bottom, 5.0)
                    HStack{
                        Image(systemName: "circle.circle")
                            .foregroundStyle(.teal)
                            .bold()
                        Spacer()
                        
                        Text("Km²")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }.padding([.leading, .trailing])
                }
            }.frame(width: 140, height: 90)
        }
    }
    
    //MARK: ‼️FUNC:SERVICIOS BÁSICOS
    func SERVICIOSBASICOS() -> some View {
        VStack {
            Text("SERVICIOS BÁSICOS")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
                .lineLimit(1)
                
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                VStack(alignment:.center){
                    HStack{
                        Image(systemName: "stethoscope")
                            .foregroundStyle(.teal)
                            .bold()
                        Text("Hospitales")
                            .font(.title3)
                            .bold()
                        
                    }.padding(5.0)
                    Divider().padding(.horizontal)
                    HStack (alignment:.center){
                        Text("Hospital mas cercano a:")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Spacer()
                        if isLoading{
                            ProgressView()
                        }else{
                            Text("2")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        Text("Km")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }.padding([.top, .leading, .trailing])
                        .padding(.bottom, 5.0)
                    Divider().padding(.horizontal)
                    HStack (alignment:.center){
                        Text("Tiempo de desplazamiento:")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Spacer()
                        if isLoading{
                            ProgressView()
                        }else{
                            Text("15")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        Text("min")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }.padding([.top, .leading, .trailing])
                        .padding(.bottom, 5.0)
                    Divider().padding(.horizontal)
                    HStack (alignment:.center){
                        Text("No. en un radio de 10 km:")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Spacer()
                        if isLoading{
                            ProgressView()
                        }else{
                            Text("15")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                        Text("hospitales")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }.padding([.top, .leading, .trailing])
                        .padding(.bottom, 5.0)
                    
                }
            }.frame(width: 370, height: 200)
        }
    }
    
    //MARK: ‼️FUNC:PELIGRO DE INUNDACIÓN
    func PELIGRODEINUNDACION() -> some View {
        VStack {
            Text("PELIGRO DE INUNDACIÓN")
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
                        Image(systemName: "water.waves.and.arrow.trianglehead.down.trianglebadge.exclamationmark")
                            
                            .foregroundStyle(.teal)
                                
                            if isLoading{
                                ProgressView()
                            }else{
                                Text("Alto")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                    }.padding([.top, .leading, .trailing])
                        .padding(.bottom, 5.0)
                    HStack{
                        
                        Spacer()
                        
                        Text("Nivel")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }.padding([.leading, .trailing])
                }
            }.frame(width: 140, height: 90)
        }
    }
    
    
    //MARK: ‼️FUNC:PRECIPITACIONES
    func PRECIPITACIONES() -> some View {
        VStack {
            Text("PRECIPITACIONES")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
                .lineLimit(1)
                
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                HStack(alignment:.center){
                    VStack(alignment:.leading){
                        Text("Umbral en 12 horas:")
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.white)
                            .padding([ .leading, .trailing])
                            .padding([.top], 5.0)
                        
                        HStack{
                            Image(systemName: "clock")
                                .foregroundStyle(.teal)
                                .bold()
                                .padding()
                            if isLoading{
                                ProgressView()
                            }else{
                                Text("50")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }.padding(.horizontal)
                        HStack{
                            Spacer()
                            Text("mm")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                                .opacity(0.5)
                                .padding(.trailing)
                        }
                    }
                    
                    Divider().padding()
                    VStack(alignment:.leading){
                        Text("Promedio anual")
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.white)
                            .padding([ .leading, .trailing])
                            .padding([.top], 5.0)
                        HStack{
                            Image(systemName: "calendar")
                                .foregroundStyle(.teal)
                                .bold()
                                .padding()
                            if isLoading{
                                ProgressView()
                            }else{
                                Text("840")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                            
                        }.padding(.horizontal)
                        HStack{
                            Spacer()
                            Text("mm")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                                .opacity(0.5)
                                .padding(.trailing)
                        }
                    }
                }
            }.frame(width: 370, height: 90)
        }
    }
}
#Preview {
    MetricsView().preferredColorScheme(.dark)
}


