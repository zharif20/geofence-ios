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
    
    func addGeofence(with viewController: UIViewController, coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, positionType: GeofenceModel.PositionType) {
        viewController.dismiss(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            let clampedRadius = min(radius, strongSelf.locationManager.maximumRegionMonitoringDistance)
            let geo = GeofenceModel(coordinate: coordinate, radius: clampedRadius, identifier: identifier, positionType: positionType)
            strongSelf.addGeofence(geofence: geo)
            strongSelf.startMonitoring(geofence: geo)
            // saveallgeofence
        }
    }
    
    func addGeofence(geofence: GeofenceModel) {
        geofences.append(geofence)
//        mapView?.addAnnotation(<#T##annotation: MKAnnotation##MKAnnotation#>)
    }
    
    func updateGeofenceCount(completion: () -> Void) {
        
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
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.changeAuthorization(manager: manager, status: status)
    }
}
