// MetricsView.swift
// cambia

import SwiftUI

struct MetricsView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var metricsViewModel: MetricsViewModel

    @State private var inegiData: InegiData? = nil
    @State private var isLoading = false

    @ObservedObject var errorDelegate = InegiDataDelegate()
    @EnvironmentObject var viewModel: CiudadMunicipioViewModel

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

    var body: some View {
        NavigationStack {
            HStack{
                VStack(spacing: 10){
                    VStack (alignment:.center, spacing: 10){
                        HStack(alignment:.top, spacing: 10){
                            DISTRIBUCIONDEVIVIENDAS()
                            
                            VStack(alignment: .center, spacing: 10){
                                HStack(alignment:.top, spacing: 10){
                                    if let data = metricsViewModel.inegiData,
                                       let value = data.indicators["densidad"],
                                       let formattedValue = formatter.string(from: NSNumber(value: value)) {
                                        RecuadroMediano(subtitle: String("DENSIDAD POBLACIONAL") , formattedValue: formattedValue, unit: String("Hab/Km²"), icon: String("person.3.fill"))
                                    }
                                    if let data = metricsViewModel.inegiData,
                                       let value = data.indicators["poblacionTotal"],
                                       let formattedValue = formatter.string(from: NSNumber(value: value)) {
                                        RecuadroMediano(subtitle: String("POBLACIÓN TOTAL") , formattedValue: formattedValue, unit: String("Personas"), icon: String("person.fill"))
                                    }
                                    //POBLACIONTOTAL()
                                }
                                
                                HStack(alignment:.center , spacing: 10){
                                    PORCENTAJEPOBREZA()
                                    PORCENTAJEinundada()
                                }
                            }
                        }
                        
                        HStack (alignment: .top, spacing: 10){
                            
                            SERVICIOSBASICOS()
                            
                            VStack(alignment:.center, spacing: 10){
                                if let area = metricsViewModel.cityArea,
                                   let formattedValue = formatter.string(from: NSNumber(value: area)) {
                                    RecuadroMediano(subtitle: String("SUPERFICIE DE LA CIUDAD") , formattedValue: formattedValue, unit: String("Km²"), icon: String("circle.circle"))
                                }else {
                                    RecuadroMediano(subtitle: String("SUPERFICIE DE LA CIUDAD") , formattedValue: String("N/A"), unit: String("Km²"), icon: String("circle.circle"))
                                }
                                if let inundatedArea = metricsViewModel.inundatedArea,
                                                                   let formattedValue = formatter.string(from: NSNumber(value: inundatedArea)) {
                                                                    RecuadroMediano(subtitle: String("ÁREA INUNDADA") , formattedValue: formattedValue, unit: String("Km²"), icon: String("water.waves"))
                                }else {
                                    RecuadroMediano(subtitle: String("ÁREA INUNDADA") , formattedValue: "N/A", unit: String("Km²"), icon: String("water.waves"))
                                    
                                }
                               // AREAINUNDADA()
                            }
                        }
                        HStack (alignment: .top, spacing: 10){
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
            .background(Color.gray5.edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            loadData()
        }
        .onChange(of: viewModel.selectedCiudadMunicipio.municipios) { oldValue, newValue in
            loadData()
        }
    }
  
    // MARK: - Función para cargar los datos usando InegiDataManager
    func loadData() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let manager = InegiDataManager()
            manager.delegate = errorDelegate
            let indicators = [
                IndicatorType.viviendasConAgua.rawValue,
                IndicatorType.viviendasConElectricidad.rawValue,
                IndicatorType.poblacionTotal.rawValue,
                IndicatorType.densidad.rawValue
            ]
            manager.fetchData(indicators: indicators, ciudad: viewModel.selectedCiudadMunicipio.ciudad.rawValue, municipio: viewModel.selectedCiudadMunicipio.municipios?.rawValue) { data in
                if let dat = data {
                    DispatchQueue.main.async {
                        isLoading = false
                        self.inegiData = dat
                        self.metricsViewModel.inegiData = dat
                    }
                }
            }
        }
    }
    
    // Indicadores específicos de INEGI y del modelo de métricas
    
    
    
    func RecuadroMediano(subtitle: String, formattedValue : String, unit: String,icon: String) -> some View {
        VStack {
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
                .lineLimit(1)
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                
                VStack {
                    if isLoading{
                        ProgressView()
                    }else{
                        Text(formattedValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.bottom)
                    }
                    HStack{
                        Image(systemName: icon)
                            .resizable()
                            .foregroundStyle(.teal)
                            .scaledToFit()
                            .frame(height: 27)
                            .padding(.bottom, 10)
                        Spacer()
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .frame(width: 140, height: 90)
        }
    }
    
    
    // Distribución de Viviendas (viviendas con electricidad y agua entubada)
    func DISTRIBUCIONDEVIVIENDAS() -> some View {
        VStack {
            Text("DISTRIBUCIÓN DE VIVIENDAS")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
            
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                
                VStack {
                    HStack {
                        Image(systemName: "percent")
                            .foregroundStyle(.teal)
                            .bold()
                        Text("Porcentajes")
                            .font(.title3)
                            .bold()
                    }
                    .padding(5.0)
                    
                    Divider()
                    
                    HStack {
                        Text("Viviendas con electricidad")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Spacer()
                        if let data = metricsViewModel.inegiData,
                           let value = data.indicators["viviendasConElectricidad"],
                           let formattedValue = formatter.string(from: NSNumber(value: value)) {
                            Text(formattedValue + " %")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Viviendas con agua entubada")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Spacer()
                        if let data = metricsViewModel.inegiData,
                           let value = data.indicators["viviendasConAgua"],
                           let formattedValue = formatter.string(from: NSNumber(value: value)) {
                            Text(formattedValue + " %")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding()
            }
            .frame(width: 200, height: 160)
        }
    }
    
    // Servicios Básicos (Hospitales)
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
                
                VStack {
                    HStack {
                        Image(systemName: "stethoscope")
                            .foregroundStyle(.teal)
                            .bold()
                        Text("Hospitales")
                            .font(.title3)
                            .bold()
                    }
                    .padding(5.0)
                    
                    Divider().padding(.horizontal)
                    
                    HStack {
                        Text("Hospital más cercano a:")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // Allow text to wrap if needed
                            .fixedSize(horizontal: false, vertical: true) // Ensure the text can grow vertically
                        
                        Spacer()
                        if metricsViewModel.nearestHospitalDistance > 0 {
                            Text(formatter.string(from: NSNumber(value: metricsViewModel.nearestHospitalDistance))! + " Km")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Divider().padding(.horizontal)
                    
                    HStack {
                        Text("Tiempo de desplazamiento:")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(metricsViewModel.travelTimeToNearestHospital) min")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    
                    Divider().padding(.horizontal)
                    
                    HStack {
                        Text("No. en un radio de 10 km:")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil) // Allow text to wrap if needed
                            .fixedSize(horizontal: false, vertical: true) // Ensure the text can grow vertically
                        
                        Spacer()

                        Text("\(metricsViewModel.numberOfHospitalsInRadius) hospitales")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                .padding()
            }
            .frame(width: 370, height: 215)
        }
    }
    
    // Otros indicadores (Pobreza, Área Inundada, Superficie, Precipitaciones, etc.)
    func PORCENTAJEPOBREZA() -> some View {
        VStack {
            Text("POBREZA")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
            
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(15)
                
                HStack {
                    Text("Pobreza")
                        .font(.caption2)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("85.42 %") // Placeholder
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .padding()
            }
            .frame(width: 140, height: 50)
        }
    }
    
    // Porcentaje de Área Inundada
    func PORCENTAJEinundada() -> some View {
        VStack {
            Text("PORCENTAJE ÁREA INUNDADA")

                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
            
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(15)

                
                HStack {
                    Text("Área Inundada")
                        .font(.caption2)
                        .foregroundStyle(.white)
                    Spacer()
                    if let floodPercentage = metricsViewModel.floodZonePercentage,
                       let formattedValue = formatter.string(from: NSNumber(value: floodPercentage)) {
                        Text(formattedValue + " %")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    } else {
                        Text("N/A")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                .padding()
            }
            .frame(width: 140, height: 50)
        }
    }
    
    // Peligro de Inundación
    func PELIGRODEINUNDACION() -> some View {
        VStack {
            Text("PELIGRO DE INUNDACIÓN")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
                .lineLimit(1)
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                
                VStack {
                    if isLoading{
                        ProgressView()
                    }else{
                        if let floodRiskLevel = metricsViewModel.floodRiskLevel {
                            Text(floodRiskLevel)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        } else {
                            Text("N/A")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                    }
                    HStack{
                        Image(systemName: "water.waves.and.arrow.trianglehead.down.trianglebadge.exclamationmark")
                            .resizable()
                            .foregroundStyle(.teal)
                            .scaledToFit()
                            .frame(height: 27)
                            .padding(.bottom, 10)
                        Spacer()
                        Text("Nivel")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .opacity(0.5)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .frame(width: 140, height: 90)
        }
        /*VStack {
            Text("PELIGRO DE INUNDACIÓN")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
            
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                
                VStack {
                    HStack {
                        Image(systemName: "water.waves.and.arrow.trianglehead.down.trianglebadge.exclamationmark")
                            .foregroundStyle(.teal)
                        
                        if let floodRiskLevel = metricsViewModel.floodRiskLevel {
                            Text(floodRiskLevel)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        } else {
                            Text("N/A")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                    }
                    Text("Nivel")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .opacity(0.5)
                }
                .padding()
            }
            .frame(width: 140, height: 90)
        }*/
    }
    
    // Precipitaciones
    func PRECIPITACIONES() -> some View {
        VStack {
            Text("PRECIPITACIONES")
                .font(.caption2)
                .foregroundStyle(.white)
                .opacity(0.5)
            
            ZStack {
                Rectangle()
                    .foregroundStyle(.gray6)
                    .opacity(0.7)
                    .cornerRadius(20)
                
                HStack {
                    // Umbral en 12 horas
                    VStack(alignment: .leading) {
                        Text("Umbral en 12 horas:")
                            .font(.caption)
                            .foregroundStyle(.white)
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(.teal)
                                .bold()
                            
                            if let hourlyPrecipitation = metricsViewModel.hourlyPrecipitation,
                               let formattedValue = formatter.string(from: NSNumber(value: hourlyPrecipitation)) {
                                Text(formattedValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            } else {
                                Text("N/A")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    
                    Divider().padding()
                    
                    // Promedio anual
                    VStack(alignment: .leading) {
                        Text("Promedio anual")
                            .font(.caption)
                            .foregroundStyle(.white)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(.teal)
                                .bold()
                            
                            if let annualPrecipitation = metricsViewModel.annualPrecipitation,
                               let formattedValue = formatter.string(from: NSNumber(value: annualPrecipitation)) {
                                Text(formattedValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            } else {
                                Text("N/A")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .padding()
            }
            .frame(width: 370, height: 90)
        }
    }
}
