//
//  AboutViewController.swift
//  icf
//
//  Created by Patrick Gröller, Christian Koller, Helmut Kopf on 22.10.15.
//  Copyright © 2015 FH. All rights reserved.
//

import UIKit
import MapKit

class AboutViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!

    let initialLocation = CLLocation(latitude: 47.453877, longitude: 15.331709)
    let regionRadius: CLLocationDistance = 1000
    let locationManager = CLLocationManager()
    let request = MKDirectionsRequest()
    //let geocoder = CLGeocoder()
    
    func centerMapOnLocation(location: CLLocation, _ title: String, _ subtitle: String, var _ distance: CLLocationDistance?) {
        if distance==nil {
            distance = regionRadius * 4.0;
        }
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, distance!, distance!)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        annotation.title = title
        annotation.subtitle = subtitle
        mapView.addAnnotation(annotation)
        
    }
    
    override func viewDidLoad() {
        centerMapOnLocation(initialLocation, "FH-Joanneum Kapfenberg", "Developers location", nil)
        
        mapView.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let distance = manager.location?.distanceFromLocation(initialLocation)
        
        centerMapOnLocation(manager.location!, "You", "Your current location", distance!*2.1)
        
        //geocoder.reverseGeocodeLocation(initialLocation, completionHandler: {
        //
        //})
        
        
        let source_place = MKPlacemark(coordinate: CLLocationCoordinate2DMake(manager.location!.coordinate.latitude, manager.location!.coordinate.longitude), addressDictionary: nil)
        request.source = MKMapItem(placemark: source_place)
        
        let target_place = MKPlacemark(coordinate: CLLocationCoordinate2DMake(initialLocation.coordinate.latitude, initialLocation.coordinate.longitude), addressDictionary: nil)
        request.destination = MKMapItem(placemark: target_place)
        
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler({(response: MKDirectionsResponse?, error: NSError?) -> Void in
            if error != nil {
                // Handle error
            } else {
                self.showRoute(response!)
            }
        })
    }
    
    func showRoute(response: MKDirectionsResponse) {
        
        for route in response.routes {
            
            mapView.addOverlay(route.polyline,
                level: MKOverlayLevel.AboveRoads)
        }
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay
        overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            
            renderer.strokeColor = UIColor.blueColor()
            renderer.lineWidth = 5.0
            return renderer
    }
    
}
