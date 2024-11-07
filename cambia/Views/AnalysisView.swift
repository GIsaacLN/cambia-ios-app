import SwiftUI

struct AnalysisView: View {
    @ObservedObject var metricsViewModel: MetricsViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Análisis de Riesgo de Inundación")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Predicción de Riesgo de Inundación
                VStack(alignment: .leading, spacing: 10) {
                    Text("Predicción de Inundación")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.2))
                            .frame(height: 80)
                        
                        HStack {
                            Image(systemName: metricsViewModel.floodRiskPrediction.contains("Alto") ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(metricsViewModel.floodRiskPrediction.contains("Alto") ? .red : .green)
                            Spacer()
                            Text(metricsViewModel.floodRiskPrediction)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Divider().background(Color.gray.opacity(0.3))
                
                // Información de las métricas
                VStack(alignment: .leading, spacing: 10) {
                    Text("Detalles del Análisis")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    MetricRow(title: "Densidad Poblacional", value: metricsViewModel.inegiData?.indicators["densidad"].map { "\(Int($0)) Hab/Km²" } ?? "No disponible")
                    MetricRow(title: "Área Inundada", value: metricsViewModel.inundatedArea.map { "\(String(format: "%.2f", $0)) Km²" } ?? "No disponible")
                    MetricRow(title: "Precipitación Anual", value: "\(Int(metricsViewModel.annualPrecipitation ?? 0)) mm")
                    MetricRow(title: "Distancia al Hospital más cercano", value: "\(String(format: "%.2f", metricsViewModel.nearestHospitalDistance)) km")
                    MetricRow(title: "Número de Hospitales en un radio de 10 km", value: "\(metricsViewModel.numberOfHospitalsInRadius)")
                    MetricRow(title: "Área Total de la Ciudad", value: "\(String(format: "%.2f", metricsViewModel.cityArea ?? 0)) Km²")
                }
                
                Spacer()
            }
            .padding()
            .background(Color.gray5.edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            metricsViewModel.performPrediction()
        }
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
