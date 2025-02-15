//
//  ViewController.swift
//  GeofenceSetel
//
//  Created by Zharif Hadi  on 25/12/2020.
//

// - Detect if device is located inside geofence area

// Geofence area: -
// geographic point == done
// radius == done
// specific wifi name == done

// Device consider to be inside geofence area if within circle or connected to specific wifi == done
// If the device located outside the zone, but still connected to specific wifi, then device is being treated as within the geofence area == done
// Able to configure geofence area and display current status (inside or outside) == done

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
        locationManager?.loadAllGeotifications()
        
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
        let long = location.longitude
        let lat = location.latitude
        
        let alert = UIAlertController(title: "Configure Area", message: "Please enter region name \n\n lat : \(lat) \n long:\(long)", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input Area Name.."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            let title = alert.textFields?[0].text

            let identifier = NSUUID().uuidString
            let geofence = GeofenceModel(coordinate: location, radius: 100, identifier: identifier, areaName: title)
            strongSelf.locationManager?.configureGeofence(with: geofence)
        }))
        
        present(alert, animated: true)
    }
    
    // MARK -: Action
    
    @IBAction func zoomToLocation(_ sender: Any) {
        mapView.zoomToCurrentLocation()
    }
    
    @IBAction func wifiSetup(_ sender: Any) {
        let alert = UIAlertController(title: "WIFI", message: "Please add SSID", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input SSID.."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
   
            let ssidAlert = alert.textFields?[0].text
            UserDefaults.standard.set(ssidAlert, forKey: "SSID")
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
        mapView.showsUserLocation = (status == .authorizedAlways)
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
    
    func locationInsideGeofence() {
        self.title = "Inside"
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    }
    
    func locationOutsideGeofence() {
        self.title = "Outside"
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    }
    
    func showError(title: String, message: String) {
        showAlert(title: title, message: message)
    }
}
