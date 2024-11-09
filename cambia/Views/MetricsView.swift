// MetricsView.swift
// cambia

import SwiftUI

struct MetricsView: View {
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var metricsViewModel: MetricsViewModel
    
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
    
    init() {
        let mapVM = MapViewModel()
        _mapViewModel = StateObject(wrappedValue: mapVM)
        _metricsViewModel = StateObject(wrappedValue: MetricsViewModel(mapViewModel: mapVM))
    }
    
    var body: some View {
        HStack {
            // Metrics Section
            VStack(spacing: 10) {
                // First Row
                HStack(alignment: .top, spacing: 10) {
                    distributionOfHousing()
                    
                    VStack(spacing: 10) {
                        populationTotal()
                        vulnerabilityIndex()
                    }
                    
                    VStack(spacing: 10) {
                        populationDensity()
                        cityArea()
                    }
                }
                
                // Second Row
                HStack(alignment: .top, spacing: 10) {
                    precipitationCard()
                    floodHazardIndex()
                }
                
                // Third Row
                HStack(alignment: .top, spacing: 10) {
                    floodedArea()
                    floodedAreaPercentage()
                }
                
                // Fourth Row
                HStack(alignment: .top, spacing: 10) {
                    hospitalsCard()
                }
                
                Spacer()
            }
            .padding()
            
            Spacer()
            
            // Map Section
            MapView(viewModel: mapViewModel)
                .padding()
        }
        .background(Color.gray5.edgesIgnoringSafeArea(.all))
        .onChange(of: settings.selectedMunicipio?.clave) { _ in
            loadData()
            metricsViewModel.updateMetrics()
        }
    }
    
    // MARK: - Data Loading
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
            
            if let jsonURL = Bundle.main.url(forResource: "inundacionmunicipio", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: jsonURL)
                    let geoJSON = try JSONDecoder().decode(GeoJSON.self, from: data)
                    
                    if let municipioFeature = geoJSON.features.first(where: { $0.properties.clv == settings.selectedMunicipio?.clave }) {
                        DispatchQueue.main.async {
                            self.metricsViewModel.cityArea = municipioFeature.properties.areaKm ?? 0.0
                            self.metricsViewModel.inundatedArea = municipioFeature.properties.areaInun ?? 0.0
                            self.metricsViewModel.populationVulnerability = municipioFeature.properties.iviPob20 ?? 0
                            self.metricsViewModel.vulnerabilityIndex = municipioFeature.properties.iviVulne ?? "N/A"
                            self.metricsViewModel.floodHazardLevel = municipioFeature.properties.peligroIn ?? "N/A"
                            self.metricsViewModel.threshold12h = municipioFeature.properties.umbral12h ?? 0.0
                        }
                    } else {
                        print("Municipio not found in JSON.")
                    }
                } catch {
                    print("Error loading or parsing JSON: \(error)")
                }
            } else {
                print("inundacionmunicipio.json not found.")
            }
        }
    }
    
    // MARK: - Reusable Metric Card View
    private func MetricCard(title: String, value: String, unit: String, icon: String? = nil, width: CGFloat = 170, height: CGFloat = 90) -> some View {
        VStack {
            Text(title)
                .font(.caption2)
                .foregroundColor(.white)
                .opacity(0.5)
                .lineLimit(1)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray6.opacity(0.7))
                
                VStack {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(value)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.bottom)
                    }
                    
                    HStack {
                        if let icon = icon {
                            Image(systemName: icon)
                                .resizable()
                                .foregroundColor(.teal)
                                .scaledToFit()
                                .frame(height: 27)
                                .padding(.bottom, 10)
                        }
                        Spacer()
                        Text(unit)
                            .font(.caption)
                            .foregroundColor(.white)
                            .opacity(0.5)
                    }
                }
                .padding()
            }
            .frame(width: width, height: height)
        }
    }
    
    // MARK: - Specific Metric Views
    private func distributionOfHousing() -> some View {
        VStack {
            Text("DISTRIBUCIÓN DE VIVIENDAS")
                .font(.caption2)
                .foregroundColor(.white)
                .opacity(0.5)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray6.opacity(0.7))
                
                VStack {
                    HStack {
                        Image(systemName: "percent")
                            .foregroundColor(.teal)
                            .bold()
                        Text("Porcentajes")
                            .font(.title3)
                            .bold()
                    }
                    .padding(5)
                    
                    Divider()
                    
                    HStack {
                        Text("Viviendas con electricidad")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text(getIndicatorValue("viviendasConElectricidad") + " %")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Viviendas con agua entubada")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text(getIndicatorValue("viviendasConAgua") + " %")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .frame(width: 220, height: 180)
        }
    }
    
    private func populationDensity() -> some View {
        MetricCard(
            title: "DENSIDAD POBLACIONAL",
            value: getIndicatorValue("densidad"),
            unit: "Hab/Km²",
            icon: "person.3.fill"
        )
    }
    
    private func populationTotal() -> some View {
        MetricCard(
            title: "POBLACIÓN TOTAL",
            value: getIndicatorValue("poblacionTotal"),
            unit: "Personas",
            icon: "person.fill"
        )
    }
    
    private func cityArea() -> some View {
        MetricCard(
            title: "SUPERFICIE DE LA CIUDAD",
            value: formatValue(metricsViewModel.cityArea),
            unit: "Km²"
        )
    }
    
    private func floodedArea() -> some View {
        MetricCard(
            title: "SUPERFICIE PROPENSA A INUNDACIONES",
            value: formatValue(metricsViewModel.inundatedArea),
            unit: "Km²",
            icon: "water.waves",
            width: 285
        )
    }
    
    private func vulnerabilityIndex() -> some View {
        MetricCard(
            title: "VULNERABILIDAD",
            value: metricsViewModel.vulnerabilityIndex ?? "N/A",
            unit: "Nivel"
        )
    }
    
    private func floodedAreaPercentage() -> some View {
        MetricCard(
            title: "PORCENTAJE ÁREA INUNDADA",
            value: formatValue(metricsViewModel.inundatedArea),
            unit: "%",
            icon: "water.waves",
            width: 280
        )
    }
    
    private func floodHazardIndex() -> some View {
        MetricCard(
            title: "PELIGRO DE INUNDACIÓN",
            value: metricsViewModel.floodHazardLevel ?? "N/A",
            unit: "Nivel",
            icon: "water.waves.and.arrow.trianglehead.down.trianglebadge.exclamationmark"
        )
    }
    
    private func precipitationCard() -> some View {
        VStack {
            Text("PRECIPITACIONES")
                .font(.caption2)
                .foregroundColor(.white)
                .opacity(0.5)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray6.opacity(0.7))
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Umbral en 12 horas:")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.teal)
                                .bold()
                            
                            Text(formatValue(metricsViewModel.hourlyPrecipitation))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Divider()
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Promedio anual")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.teal)
                                .bold()
                            
                            Text(formatValue(metricsViewModel.annualPrecipitation))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
            .frame(width: 400, height: 90)
        }
    }
    
    private func hospitalsCard() -> some View {
        VStack {
            Text("SERVICIOS BÁSICOS")
                .font(.caption2)
                .foregroundColor(.white)
                .opacity(0.5)
                .lineLimit(1)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray6.opacity(0.7))
                
                VStack {
                    HStack {
                        Image(systemName: "stethoscope")
                            .foregroundColor(.teal)
                            .bold()
                        Text("Hospitales")
                            .font(.title3)
                            .bold()
                    }
                    .padding(5)
                    
                    Divider().padding(.horizontal)
                    
                    HStack {
                        Text("Hospital más cercano a:")
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        Text(formatValue(metricsViewModel.nearestHospitalDistance) + " Km")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Divider().padding(.horizontal)
                    
                    HStack {
                        Text("Tiempo de desplazamiento:")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(metricsViewModel.travelTimeToNearestHospital) min")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Divider().padding(.horizontal)
                    
                    HStack {
                        Text("No. en un radio de 10 km:")
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        Text("\(metricsViewModel.numberOfHospitalsInRadius) hospitales")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .frame(width: 370, height: 215)
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

#Preview {
    MetricsView()
        .environmentObject(SelectedMunicipio())
}
