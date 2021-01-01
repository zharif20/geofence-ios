//
//  GeofenceModel.swift
//  GeofenceSetel
//
//  Created by Zharif Hadi  on 02/01/2021.
//

import CoreLocation

struct GeofenceModel {
    enum PositionType {
        case inside
        case outside
    }
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var positionType: PositionType
}
