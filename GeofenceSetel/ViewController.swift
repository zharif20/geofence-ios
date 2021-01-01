//
//  ViewController.swift
//  GeofenceSetel
//
//  Created by Zharif Hadi  on 25/12/2020.
//

// - Detect if device is located inside geofence area

// Geofence area: -
// geographic point
// radius
// specific wifi name

// Device consider to be inside geofence area if within circle or connected to specific wifi
// If the device located outside the zone, but still connected to specific wifi, then device is being treated as within the geofence area
// Able to configure geofence area and display current status (inside or outside)

//Grant access to engineering@setel.my

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    var locationManager: LocationManager?

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = LocationManager()
        locationManager?.delegate = self
    }
    
    // MARK -: Functions
    func region(geofence: GeofenceModel) -> CLCircularRegion {
        let region = CLCircularRegion(center: geofence.coordinate, radius: geofence.radius, identifier: geofence.identifier)
        
        region.notifyOnEntry = geofence.positionType == .inside
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }


    // MARK -: Action
    
    @IBAction func zoomToLocation(_ sender: Any) {
        mapView.zoomToCurrentLocation()
    }
}

extension ViewController: LocationManagerDelegate {
    func changeAuthorization(manager: CLLocationManager, status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways || status == .authorizedWhenInUse)
    }
}
