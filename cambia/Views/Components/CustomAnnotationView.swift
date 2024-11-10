//
//  CustomAnnotationView.swift
//  cambia
//
//  Created by Gustavo Isaac Lopez Nunez on 10/11/24.
//

import SwiftUI
import MapKit

struct CustomAnnotationView: UIViewRepresentable {
    let annotation: MKAnnotation
    let color: UIColor

    func makeUIView(context: Context) -> MKMarkerAnnotationView {
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        view.markerTintColor = color
        return view
    }

    func updateUIView(_ uiView: MKMarkerAnnotationView, context: Context) {
        uiView.annotation = annotation
        uiView.markerTintColor = color
    }
}
