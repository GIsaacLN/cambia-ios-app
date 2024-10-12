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
    
    init() {
        let mapVM = MapViewModel()
        _mapViewModel = StateObject(wrappedValue: mapVM)
        _metricsViewModel = StateObject(wrappedValue: MetricsViewModel(mapViewModel: mapVM))
    }
    
    var body: some View {
        HStack {
            VStack {
                Text("Metrics")
                    .font(.title3)
                    .bold()
                Divider()
                
                if mapViewModel.selectedLayers.contains(where: { $0.name == "Hospitals" }) {
                    VStack {
                        HStack {
                            Text("Nearest Hospital Distance:")
                                .font(.caption)
                            Spacer()
                            Text(String(format: "%.2f", metricsViewModel.nearestHospitalDistance))
                                .foregroundStyle(Color.orange)
                                .font(.title)
                                .bold()
                            Text("Km")
                                .font(.caption)
                        }
                        Divider()
                        HStack {
                            Text("Number of Hospitals in Radius:")
                                .font(.caption)
                            Spacer()
                            Text("\(metricsViewModel.numberOfHospitalsInRadius)")
                                .foregroundStyle(Color.orange)
                                .font(.title)
                                .bold()
                        }
                    }
                }
                
                if mapViewModel.selectedLayers.contains(where: { $0.name == "Flood Zones" }) {
                    VStack {
                        HStack {
                            Text("Flood Zone Info:")
                                .font(.caption)
                            Spacer()
                            Text(metricsViewModel.floodZoneInfo)
                                .foregroundStyle(Color.orange)
                                .font(.title)
                                .bold()
                        }
                    }
                }
                // Add more metrics for other layers as needed
                
            }
            .padding()
            .background(Color.gray6)
            .cornerRadius(20)
            .opacity(0.7)
            MapView(viewModel: mapViewModel)
        }
    }
}
