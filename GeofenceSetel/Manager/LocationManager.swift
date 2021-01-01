//
//  LocationManager.swift
//  GeofenceSetel
//
//  Created by Zharif Hadi  on 27/12/2020.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func changeAuthorization(manager: CLLocationManager, status: CLAuthorizationStatus)
}

class LocationManager: NSObject {
    
    var locationManager:CLLocationManager!
    var delegate:LocationManagerDelegate? = nil
    
    static let sharedInstance = LocationManager()
    
    override init() {
        super.init()
        
        initCoreLocation()
    }
    
    private func initCoreLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.changeAuthorization(manager: manager, status: status)
    }
}
