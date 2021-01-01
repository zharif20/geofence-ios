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
    
    func region(geofence: GeofenceModel) -> CLCircularRegion {
        let region = CLCircularRegion(center: geofence.coordinate, radius: geofence.radius, identifier: geofence.identifier)
        
        region.notifyOnEntry = geofence.positionType == .inside
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    // Monitor geofence when user add
    func startMonitoring(geofence: GeofenceModel) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
//            showAlert(title: "Error", message: "Geofence is not supported by this device")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways ||
            CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
//            showAlert(title: "Error", message: "Permission to access location is needed")
            return
        }
        
        let geofenceRegion = region(geofence: geofence)
        locationManager.startMonitoring(for: geofenceRegion)
    }
    
    func stopMonitoring(geofence: GeofenceModel) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geofence.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
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
