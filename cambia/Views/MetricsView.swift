// MetricsView.swift
// cambia

import SwiftUI

struct MetricsView: View {
    @EnvironmentObject private var mapViewModel: MapViewModel
    @EnvironmentObject private var metricsViewModel: MetricsViewModel
    @EnvironmentObject var settings: SelectedMunicipio
    @State private var isLoading = false
    @ObservedObject var errorDelegate = InegiDataDelegate()
    
    // Number formatter for consistent formatting
    private var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","
        return formatter
    }
        
    var body: some View {
        ZStack{
            Color.gray5.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionView(title: "Distribución de Viviendas", icon: "house.fill") {
                        HStack {
                            MetricCardView(title: "Acceso a electricidad", value: getIndicatorValue("viviendasConElectricidad") + " %", icon: Image(systemName: "bolt.fill"), isLoading: isLoading)
                            MetricCardView(title: "Acceso a agua", value: getIndicatorValue("viviendasConAgua") + " %", icon: Image(systemName: "drop.fill"), isLoading: isLoading)
                        }
                    }
                    
                    SectionView(title: "Demografía", icon: "person.3.fill") {
                        HStack {
                            MetricCardView(title: "Densidad Poblacional", value: getIndicatorValue("densidad"), icon: Image(systemName: "person.3.fill"), isLoading: isLoading)
                            MetricCardView(title: "Población Total", value: getIndicatorValue("poblacionTotal"), icon: Image(systemName: "person.fill"), isLoading: isLoading)
                        }
                    }
                    
                    SectionView(title: "Servicios Básicos", icon: "stethoscope") {
                        let columns = [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            MetricCardView(
                                title: "Hospitales",
                                value: "\(metricsViewModel.totalHospitalsInMunicipio) en total",
                                icon: Image(systemName: "cross.fill"),
                                footer: "Distancia promedio: \(formatValue(metricsViewModel.averageHospitalDistance)) km",
                                isLoading: isLoading
                            )
                            
                            MetricCardView(
                                title: "Policía",
                                value: "\(metricsViewModel.totalPoliceStationsInMunicipio) estaciones",
                                icon: Image(systemName: "shield.fill"),
                                footer: "Distancia promedio: \(formatValue(metricsViewModel.averagePoliceStationDistance)) km",
                                isLoading: isLoading
                            )
                            
                            MetricCardView(
                                title: "Bomberos",
                                value: "\(metricsViewModel.totalFireStationsInMunicipio) estaciones",
                                icon: Image(systemName: "flame.fill"),
                                footer: "Distancia promedio: \(formatValue(metricsViewModel.averageFireStationDistance)) km",
                                isLoading: isLoading
                            )
                        }
                    }

                    SectionView(title: "Inundaciones y Peligro", icon: "exclamationmark.triangle.fill") {
                        HStack {
                            MetricCardView(title: "Área Inundada", value: formatValue(settings.selectedMunicipio?.inundatedArea) + " Km²", icon: Image(systemName: "drop.triangle.fill"), isLoading: isLoading)
                            MetricCardView(title: "Peligro de Inundación", value: settings.selectedMunicipio?.floodHazardLevel ?? "N/A", icon: Image(systemName: "exclamationmark.triangle.fill"), color: .red.opacity(0.2), isLoading: isLoading)
                        }
                    }
                    
                    SectionView(title: "Precipitaciones", icon: "cloud.rain.fill") {
                        HStack {
                            MetricCardView(title: "Umbral en 12 horas", value: formatValue(metricsViewModel.hourlyPrecipitation) + " mm", icon: Image(systemName: "clock"), isLoading: isLoading)
                            MetricCardView(title: "Promedio anual", value: formatValue(metricsViewModel.annualPrecipitation) + " mm", icon: Image(systemName: "calendar"), isLoading: isLoading)
                        }
                    }
                }
                .onChange(of: settings.selectedMunicipio?.clave) {
                    loadData()
                    metricsViewModel.updateMetrics()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - Loading Data
    private func loadData() {
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
            
            manager.fetchData(indicators: indicators, municipio: settings.selectedMunicipio?.clave) { data in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let fetchedData = data {
                        self.metricsViewModel.inegiData = fetchedData
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getIndicatorValue(_ key: String) -> String {
        if let data = metricsViewModel.inegiData,
           let value = data.indicators[key],
           let formattedValue = formatter.string(from: NSNumber(value: value)) {
            return formattedValue
        } else {
            return "N/A"
        }
    }
    
    private func formatValue(_ value: Double?) -> String {
        if let value = value,
           let formattedValue = formatter.string(from: NSNumber(value: value)) {
            return formattedValue
        } else {
            return "N/A"
        }
    }
}

struct GroupedMetricView: View {
    let title: String
    let metrics: [(title: String, value: String, icon: Image)]
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(metrics, id: \.title) { metric in
                MetricCardView(
                    title: metric.title,
                    value: metric.value,
                    icon: metric.icon,
                    isLoading: isLoading
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.teal)
                Text(title)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            content
        }
    }
}

#Preview {
    MetricsView()
        .environmentObject(SelectedMunicipio())
        .environmentObject(MapViewModel())
        .environmentObject(MetricsViewModel())
}
