//
//  GeofenceModel.swift
//  GeofenceSetel
//
//  Created by Zharif Hadi  on 02/01/2021.
//

import CoreLocation
import MapKit

class GeofenceModel: NSObject, Codable, MKAnnotation {
    enum PositionType: String {
        case inside = "inside"
        case outside = "outside"
    }
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var positionType: PositionType
    
    var title: String? = "Note"
    
    var subtitle: String? = "Hi"
    
    enum CodingKeys: String, CodingKey {
      case latitude, longitude, radius, identifier, positionType
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, positionType: PositionType) {
      self.coordinate = coordinate
      self.radius = radius
      self.identifier = identifier
      self.positionType = positionType
    }
    
    // MARK: Codable
    required init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      let latitude = try values.decode(Double.self, forKey: .latitude)
      let longitude = try values.decode(Double.self, forKey: .longitude)
      coordinate = CLLocationCoordinate2DMake(latitude, longitude)
      radius = try values.decode(Double.self, forKey: .radius)
      identifier = try values.decode(String.self, forKey: .identifier)
      let event = try values.decode(String.self, forKey: .positionType)
        positionType = PositionType(rawValue: event) ?? .inside
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(coordinate.latitude, forKey: .latitude)
      try container.encode(coordinate.longitude, forKey: .longitude)
      try container.encode(radius, forKey: .radius)
      try container.encode(identifier, forKey: .identifier)
      try container.encode(positionType.rawValue, forKey: .positionType)
    }
}
