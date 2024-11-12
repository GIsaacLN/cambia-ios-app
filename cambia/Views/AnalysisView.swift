import SwiftUI
import Charts

struct AnalysisView: View {
    @EnvironmentObject var metricsViewModel: MetricsViewModel
    @EnvironmentObject var settings: SelectedMunicipio
    
    @State var oberlayDataServivios: Bool = false
    @State var showDistribucionOverlay: Bool = false
    @State var ShowPrediccióndeInundación: Bool = true
    @State var predictionText: String = "Cargando datos..."
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color.gray5.ignoresSafeArea()
                
                ScrollView{
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("Análisis de Riesgo de Inundación")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        // Predicción de Riesgo de Inundación
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Predicción de Inundación")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(riskColor)
                                    .frame(height: 80)
                                
                                HStack {
                                    Image(systemName: riskIcon)
                                        .font(.system(size: 40))
                                        .foregroundColor(riskColor.opacity(0.8))
                                    Spacer()
                                    
                                    Text(metricsViewModel.floodRiskPrediction)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Button {
                                        ShowPrediccióndeInundación.toggle()
                                    } label: {
                                        Image(systemName: "info.circle")
                                            .foregroundStyle(.teal)
                                    }.padding()
                                    
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        if ShowPrediccióndeInundación{
                            Divider().background(Color.gray.opacity(0.3))
                            
                            // Información de las métricas
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Detalles del Análisis")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                MetricRow(title: "Densidad Poblacional", value: metricsViewModel.inegiData?.indicators["densidad"].map { "\(Int($0)) Hab/Km²" } ?? "No disponible")
                                MetricRow(title: "Área Inundada", value: settings.selectedMunicipio?.inundatedArea.map() { "\(String(format: "%.2f", $0)) Km²" } ?? "No disponible")
                                MetricRow(title: "Precipitación Anual", value: "\(Int(metricsViewModel.annualPrecipitation ?? 0)) mm")
                                MetricRow(title: "Distancia promedio al Hospital más cercano", value: "\(String(format: "%.2f", metricsViewModel.averageHospitalDistance)) km")
                                MetricRow(title: "Número de Hospitales en un radio de 10 km", value: "\(metricsViewModel.totalHospitalsInMunicipio)")
                                MetricRow(title: "Área Total de la Ciudad", value: "\(String(format: "%.2f", settings.selectedMunicipio?.cityArea ?? 0)) Km²")
                            }
                        }
                        ScrollView (.horizontal){
                            HStack{
                                GraficaServiciosBasicos()
                                    .padding()
                                GraficaDistribucionViviendas()
                                    .padding()
                            }
                            .padding()
                        }
                        Spacer()
                        
                    }
                    .padding()
                    .background(Color.gray5.edgesIgnoringSafeArea(.all))
                }
                .preferredColorScheme(.dark)
            }
        }
        .onAppear {
            updatePrediction()
        }
        .onChange(of: settings.selectedMunicipio?.clave) {
            updatePrediction()
        }
    }
    
    // Helper function to handle prediction updates
    private func updatePrediction() {
        metricsViewModel.performPrediction(selectedMunicipio: settings.selectedMunicipio)
        predictionText = metricsViewModel.floodRiskPrediction
    }
    
    // Computed property para obtener el color según el nivel de riesgo
    private var riskColor: Color {
        switch metricsViewModel.floodRiskPrediction {
        case "Peligro de inundación: Muy bajo":
            return .green.opacity(0.2)
        case "Peligro de inundación: Bajo":
            return .blue.opacity(0.2)
        case "Peligro de inundación: Medio":
            return .yellow.opacity(0.2)
        case "Peligro de inundación: Alto":
            return .orange.opacity(0.2)
        case "Peligro de inundación: Muy alto":
            return .red.opacity(0.2)
        default:
            return .gray.opacity(0.2)
        }
    }
    
    // Computed property para obtener el ícono según el nivel de riesgo
    private var riskIcon: String {
        switch metricsViewModel.floodRiskPrediction {
        case "Peligro de inundación: Muy bajo", "Peligro de inundación: Bajo":
            return "checkmark.circle.fill"
        case "Peligro de inundación: Medio", "Peligro de inundación: Alto", "Peligro de inundación: Muy alto":
            return "exclamationmark.triangle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    func GraficaServiciosBasicos() -> some View {
        VStack {
            Text("Servicios Básicos")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Chart {
                BarMark(
                    x: .value("Servicio", "Hospitales"),
                    y: .value("Cantidad", metricsViewModel.totalHospitalsInMunicipio)
                )
                .foregroundStyle(.red)
                BarMark(
                    x: .value("Servicio", "Policía"),
                    y: .value("Cantidad", metricsViewModel.totalPoliceStationsInMunicipio)
                )
                .foregroundStyle(.blue)
                
                BarMark(
                    x: .value("Servicio", "Bomberos"),
                    y: .value("Cantidad", metricsViewModel.totalFireStationsInMunicipio)
                )
                .foregroundStyle(.yellow)
            }
            .frame(width: 250, height: 250)
            .onTapGesture {
                oberlayDataServivios.toggle()
            }
            .overlay{
                if oberlayDataServivios {
                    VStack (alignment: .leading){
                        Text("Interpretación")
                            .font(.headline)
                            .padding(.bottom, 5)
                        Text("HOSPITALES")
                            .font(.caption2)
                            .foregroundStyle(.white,.opacity(50))
                        
                        Text(serviceDescription(for:"Hospitales"))
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        Divider()
                        Text("POLICÍA")
                            .font(.caption2)
                            .foregroundStyle(.white,.opacity(50))
                        Text(serviceDescription(for:"Policía"))
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        Divider()
                        Text("BOMBEROS")
                            .font(.caption2)
                            .foregroundStyle(.white,.opacity(50))
                        
                        Text(serviceDescription(for:"Bomberos"))
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                    }
                    .padding()
                    .frame(width: 240, height: 300)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .onTapGesture {
                        oberlayDataServivios.toggle()
                    }
                }
            }
            
        }
        .padding()
        
    }
    
    
    func GraficaDistribucionViviendas() -> some View {
        let viviendaData = [
            ("Electricidad", metricsViewModel.inegiData?.indicators["viviendasConElectricidad"]),
            ("Agua", metricsViewModel.inegiData?.indicators["viviendasConAgua"] ?? 0)
        ]
        
        return VStack {
            Text("Distribución de Viviendas")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Chart(viviendaData, id: \.0) { data in
                BarMark(
                    x: .value("Tipo", data.0),
                    y: .value("Porcentaje", data.1 ?? 0)
                )
                .foregroundStyle(by: .value("Tipo", data.0))
            }
            .frame(width: 250, height: 250)
            .onTapGesture {
                showDistribucionOverlay.toggle()
            }
            .overlay {
                if showDistribucionOverlay {
                    VStack(alignment: .leading) {
                        Text("Interpretación:")
                            .font(.headline)
                            .padding(.bottom, 5)
                        Text(viviendasDescription())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .onTapGesture {
                        showDistribucionOverlay.toggle()
                    }
                }
            }
        }
        .padding()
    }
    
    private func serviceDescription(for service: String) -> String {
        guard let population = metricsViewModel.inegiData?.indicators["poblacionTotal"] else {
            return "Datos de población no disponibles."
        }
        
        let serviceCount: Int
        let description: String
        
        switch service {
        case "Hospitales":
            serviceCount = metricsViewModel.totalHospitalsInMunicipio
            description = "Un hospital disponible por cada \(Int(population) / max(serviceCount, 1)) habitantes."
        case "Policía":
            serviceCount = metricsViewModel.totalPoliceStationsInMunicipio
            description = "Una estación de policía por cada \(Int(population) / max(serviceCount, 1)) habitantes."
        case "Bomberos":
            serviceCount = metricsViewModel.totalFireStationsInMunicipio
            description = "Una estación por cada \(Int(population) / max(serviceCount, 1)) habitantes"
        default:
            description = "Datos no disponibles para este servicio."
        }
        
        return description
    }
    
    private func viviendasDescription() -> String {
        guard let electricidad = metricsViewModel.inegiData?.indicators["viviendasConElectricidad"],
              let agua = metricsViewModel.inegiData?.indicators["viviendasConAgua"] else {
            return "Datos de distribución de viviendas no disponibles."
        }
        
        return """
        En este municipio, el \(String(format: "%.2f", electricidad))% de las viviendas tienen acceso a electricidad y el \(String(format: "%.2f", agua))% tienen acceso a agua potable. 
        """
    }
}


// Componentes de UI reutilizables
struct MetricRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview{
    AnalysisView()
        .environmentObject(MetricsViewModel())
        .environmentObject(SelectedMunicipio())
}
