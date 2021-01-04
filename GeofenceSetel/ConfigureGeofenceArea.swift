//
//  ConfigureGeofenceArea.swift
//  GeofenceSetel
//
//  Created by Zharif Hadi  on 03/01/2021.
//

import UIKit
import MapKit

class ConfigureGeofenceArea: UITableViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addGeofence(_ sender: Any) {
        
    }
    
    @IBAction func zoomToCurrentLocation(_ sender: Any) {
        mapView.zoomToCurrentLocation()
    }
}
