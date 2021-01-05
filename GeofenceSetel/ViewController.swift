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
        
        mapView.delegate = self
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(addGeofence))
            mapView.addGestureRecognizer(longTapGesture)
    }
    
    // MARK -: Functions
    @objc func addGeofence(sender: UIGestureRecognizer){
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
    }
    
    func addAnnotation(location: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "New Area"
        annotation.subtitle = "Get inside"
        
        let identifier = NSUUID().uuidString
        let geofence = GeofenceModel(coordinate: location, radius: 100, identifier: identifier, positionType: .inside)
        locationManager?.configureGeofence(with: geofence)
        mapView.addAnnotation(annotation)
    }
    
    // MARK -: Action
    
    @IBAction func zoomToLocation(_ sender: Any) {
        mapView.zoomToCurrentLocation()
    }
    
    @IBAction func wifiSetup(_ sender: Any) {
        let alert = UIAlertController(title: "WIFI", message: "Please add SSID and BSSID", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input SSID.."
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input BSSID.."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
   
            let ssidAlert = alert.textFields?[0].text
            let bssidAlert = alert.textFields?[1].text
            
            UserDefaults.standard.set(ssidAlert, forKey: "SSID")
            UserDefaults.standard.set(bssidAlert, forKey: "BSSID")
 
        }))
        
        present(alert, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRender = MKCircleRenderer(overlay: overlay)
            circleRender.lineWidth = 1.0
            circleRender.strokeColor = .red
            circleRender.fillColor = UIColor.red.withAlphaComponent(0.4)
            return circleRender
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is GeofenceModel else { return nil }

        let mapIdentifier = "geofenceId"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mapIdentifier) as? MKPinAnnotationView
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: mapIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.leftCalloutAccessoryView = UIButton(type: .close)
            annotationView?.pinTintColor = .black
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            guard let geofence = view.annotation as? GeofenceModel else { return }
            locationManager?.removeGeofence(remove: geofence)
        }
    }
}

extension ViewController: LocationManagerDelegate {
    func changeAuthorization(manager: CLLocationManager, status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways || status == .authorizedWhenInUse)
    }
    
    func addRadiusOverlay(geofence: GeofenceModel) {
        mapView.addAnnotation(geofence)
        mapView.addOverlay(MKCircle(center: geofence.coordinate, radius: geofence.radius))
    }
    
    func removeRadiusOverlay(geofence: GeofenceModel) {
        mapView.removeAnnotation(geofence )

        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geofence.coordinate.latitude && coord.longitude == geofence.coordinate.longitude && circleOverlay.radius == geofence.radius {
                mapView?.removeOverlay(circleOverlay)
              break
            }
        }
    }
}
