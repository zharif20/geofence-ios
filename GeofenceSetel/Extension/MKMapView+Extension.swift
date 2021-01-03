//
//  MKMapView+Extension.swift
//  GeofenceSetel
//
//  Created by Zharif Hadi  on 01/01/2021.
//

import Foundation
import MapKit

extension MKMapView {
    
    func zoomToCurrentLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        setRegion(region, animated: true)
        addOverlay(MKCircle(center: coordinate, radius: 100))
    }
    
}
