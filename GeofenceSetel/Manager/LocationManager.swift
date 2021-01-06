//
//  LocationManager.swift
//  GeofenceSetel
//
//  Created by Zharif Hadi  on 27/12/2020.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

protocol LocationManagerDelegate: class {
    func changeAuthorization(manager: CLLocationManager, status: CLAuthorizationStatus)
    func locationOutsideGeofence()
    func locationInsideGeofence()
    func addRadiusOverlay(geofence: GeofenceModel)
    func removeRadiusOverlay(geofence: GeofenceModel)
    func showError(title: String, message: String)
}

class LocationManager: NSObject {
    
    var locationManager:CLLocationManager!
    var delegate:LocationManagerDelegate? = nil
    var geofences: [GeofenceModel] = []
    var mapView: MKMapView?
    
    static let sharedInstance = LocationManager()
    
    override init() {
        super.init()
        
        initCoreLocation()
    }
    
    private func initCoreLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func region(geofence: GeofenceModel) -> CLCircularRegion {
        let region = CLCircularRegion(center: geofence.coordinate, radius: geofence.radius, identifier: geofence.identifier)
        
        region.notifyOnEntry = true
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    // Monitor geofence when user add
    func startMonitoring(geofence: GeofenceModel) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            delegate?.showError(title: "Error", message: "Geofence is not supported by this device")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            delegate?.showError(title: "Error", message: "Permission to access location is needed")
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
    
    func configureGeofence(with geofence: GeofenceModel) {
        let clampedRadius = min(geofence.radius, locationManager.maximumRegionMonitoringDistance)
        let geo = GeofenceModel(coordinate: geofence.coordinate, radius: clampedRadius, identifier: geofence.identifier, areaName: geofence.areaName)
        addGeofence(add: geo)
        startMonitoring(geofence: geo)
        saveAllGeotifications()
    }
    
    func addGeofence(add geofence: GeofenceModel) {
        geofences.append(geofence)
        delegate?.addRadiusOverlay(geofence: geofence)
    }
    
    func removeGeofence(remove geofence: GeofenceModel) {
        guard let index = geofences.firstIndex(of: geofence) else { return }
        geofences.remove(at: index)
        delegate?.removeRadiusOverlay(geofence: geofence)
    }
    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        geofences.removeAll()
        let allGeotifications = GeofenceModel.allGeotifications()
        allGeotifications.forEach { addGeofence(add: $0) }
    }
    
    func saveAllGeotifications() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(geofences)
            UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems)
        } catch {
            print("error encoding geotifications")
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for identifier: \(region?.identifier ?? "") with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location failed with error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // check wifi and region logic        
        if !Utilities.sharedInstance.hasWifi() && locationManager.monitoredRegions.count == 0 { // no wifi and outside region
            // status should be outside
            delegate?.locationOutsideGeofence()
            
        } else if Utilities.sharedInstance.hasWifi() { // got wifi
            delegate?.locationInsideGeofence()
        } else { // no wifi but still inside region
            delegate?.locationInsideGeofence()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.changeAuthorization(manager: manager, status: status)
    }
}
