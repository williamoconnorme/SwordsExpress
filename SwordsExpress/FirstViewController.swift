//
//  FirstViewController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 30/07/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit
import MapKit

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var SegController: UISegmentedControl!
    @IBOutlet weak var RouteSegControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    let dataManager = DataManager()
    let manager = CLLocationManager()
    var polyline = MKPolyline()
    let waypoints = Waypoints()
    var lastCoord = [Double]()
    
    var busAnnotations = MKPointAnnotation()
    var stopAnnotations = MKPointAnnotation()
    
    
    
    // Segment controller for changing annotations
    @IBAction func ShowHideAnnotations(_ sender: Any) {
        
        switch SegController.selectedSegmentIndex {
        case 0:
            // Remove Annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.RouteSegControl.selectedSegmentIndex = -1
            self.mapView.remove(polyline)
            addBusStopsToCity()
        case 1:
            // Remove Annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.RouteSegControl.selectedSegmentIndex = -1
            self.mapView.remove(polyline)
            addBusStopsToSwords()
        default:
            // Remove Annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }
    
    @IBAction func ShowHidePolyline(_ sender: Any) {
        switch RouteSegControl.selectedSegmentIndex {
        case 0: //500
            self.mapView.remove(polyline)
            addPolyline(wayPointArr: waypoints.waypoints500fromSwords)
            appendPolyLine(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 1: //501
            self.mapView.remove(polyline)
            addPolyline(wayPointArr: waypoints.waypoints501fromSwords)
            appendPolyLine(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 2: //502
            self.mapView.remove(polyline)
            addPolyline(wayPointArr: waypoints.waypoints502fromSwords)
            appendPolyLine(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 3: //503
            self.mapView.remove(polyline)
            addPolyline(wayPointArr: waypoints.waypoints502fromSwords) // Change THIS
            appendPolyLine(wayPointArr: waypoints.waypointsPearseGardaToMerrionSq)
        case 4: //504
            self.mapView.remove(polyline)
            addPolyline(wayPointArr: waypoints.waypoints504fromSwords)
            
            
        case 5: //505
            self.mapView.remove(polyline)
            addPolyline(wayPointArr: waypoints.waypoints505fromSwords)
            appendPolyLine(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 6: //506
            self.mapView.remove(polyline)
            addPolyline(wayPointArr: waypoints.waypoints505fromSwords) // Change THIS
        case 7: //507
            self.mapView.remove(polyline)
            addPolyline(wayPointArr: waypoints.waypoints507fromSwords)
            appendPolyLine(wayPointArr: waypoints.waypointsIfscToEdenQ)
        default:
            self.mapView.remove(polyline)
        }
    }
    
    
    
    let busStopsToCity =
        [
            [53.4596654, -6.2503624, 333, 1],
            [53.459984, -6.245307, 334, 2],
            [53.4606895, -6.2413665, 339, 3],
            [53.4625433, -6.2398851, 338, 4],
            [53.463878, -6.239549, 337, 5],
            [53.4657815, -6.2397887, 336, 6],
            [53.468251, -6.2367971, 339, 7],
            [53.4694079, -6.2308137, 340, 8],
            [53.4686893, -6.2279908, 341, 9],
            [53.4682362, -6.2209795, 342, 10],
            [53.4650053, -6.2173297, 343, 11],
            [53.4622247, -6.2131752, 344, 12],
            [53.4569384, -6.2124503, 345, 13],
            [53.454165, -6.215768, 582, 14],
            [53.454629, -6.2183, 347, 15],
            [53.4558985, -6.2217432, 348, 16],
            [53.4543519, -6.2243928, 583, 17],
            [53.4526008, -6.2272095, 587, 18],
            [53.4455748, -6.2352678, 351, 19],
            [53.444665, -6.231174, 352, 20],
            [53.4449935, -6.2271727, 353, 21],
            [53.446006, -6.2243145, 354, 22],
            [53.443639, -6.2111045, 355, 23],
            [53.4434736, -6.2093203, 356, 24],
            [53.3507872, -6.2259726, 357, 25],
            [53.3474227, -6.2397389, 584, 26],
            [53.3479217, -6.247108, 585, 27],
            [53.348063, -6.256350, 586, 28]
    ]
    
    let busStopsToSwords =
        [
            [53.3477969, -6.2584213, 555, 29],
            [53.3482716, -6.2502319, 556, 30],
            [53.3481121, -6.2472811, 557, 31],
            [53.3477493, -6.2423821, 558, 32],
            [53.3473521, -6.2364198, 559, 33],
            [53.346875, -6.228919, 560, 34],
            [53.4434416, -6.2111721, 562, 35],
            [53.446133, -6.222701, 563, 36],
            [53.444509, -6.231292, 564, 37],
            [53.445133, -6.235007, 565, 38],
            [53.4521321, -6.2286058, 566, 39],
            [53.4544301, -6.224466, 567, 40],
            [53.45538, -6.222422, 568, 41],
            [53.454339, -6.216293, 569, 42],
            [53.461677, -6.2134949, 570, 43],
            [53.464877, -6.2169974, 571, 44],
            [53.4680775, -6.2215895, 572, 45],
            [53.4684694, -6.2275828, 573, 46],
            [53.4695937, -6.2318054, 574, 47],
            [53.4683705, -6.2362437, 575, 48],
            [53.4666115, -6.2392209, 576, 49],
            [53.4656155, -6.2396175, 577, 50],
            [53.4641399, -6.239343, 578, 51],
            [53.4616212, -6.2403112, 579, 52],
            [53.4598859, -6.2417255, 580, 53],
            [53.459853, -6.245138, 581, 54],
            [53.339029, -6.249886, 581, 55]
    ]
    
    func addPolyline(wayPointArr: [Array<Double>]) {
        
        let waypoint = wayPointArr.map { CLLocationCoordinate2DMake($0[0], $0[1]) }
        lastCoord = wayPointArr.last!
        polyline = MKPolyline(coordinates: waypoint, count: waypoint.count)
        mapView?.add(polyline)
        
    }
    
    func appendPolyLine(wayPointArr: [Array<Double>]) {
        var connectedWaypoint = wayPointArr
        connectedWaypoint.insert(lastCoord, at: 0)
        let waypoint = connectedWaypoint.map { CLLocationCoordinate2DMake($0[0], $0[1]) }
        polyline = MKPolyline(coordinates: waypoint, count: waypoint.count)
        mapView?.add(polyline)
    }
    
    func addBusStopsToCity() {
        
        for entries in busStopsToCity {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(entries[0], entries[1])
            //let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(entries[0], entries[1])
            //annotation.coordinate = location
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func addBusStopsToSwords() {
        for entries in busStopsToSwords {
            
            stopAnnotations = MKPointAnnotation()
            stopAnnotations.coordinate = CLLocationCoordinate2DMake(entries[0], entries[1])
            
            self.mapView.addAnnotation(stopAnnotations)
        }
    }
    
    class BusAnnotation : MKPointAnnotation {
        var pinTintColor: UIColor?
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
        
        //        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        //        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        //Map.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Plot bus stops to city by default
        addBusStopsToCity()

        // Plot buses for first time
        dataManager.getLocations(completionHandler: { (BusObj) in
            
            DispatchQueue.main.sync {
                let buses = (self.dataManager.BusObj)
                
                for entries in buses {
                    self.busAnnotations = BusAnnotation()
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(entries.Longitude, entries.Latitude)
                    self.busAnnotations.coordinate = location
                    self.busAnnotations.title = entries.Registration
                    
                    self.busAnnotations.subtitle = entries.Speed
                    self.mapView.addAnnotation(self.busAnnotations)
                }
            }
            
        })
        
        //Update bus locations test
        startUpdatingPositions()
        
        // User Location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
        // Zoom in on Swords
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region1 = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.4557, longitude: -6.2197), span: span)
            self.mapView.setRegion(region1, animated: true)
        })
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    weak var timer: Timer?
    
    func startUpdatingPositions() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.dataManager.updateLocations(completionHandler: { (BusObj) in
                //self?.mapView.removeAnnotations(busAnnotation)
                DispatchQueue.main.sync {
                    
                    let buses = (self?.dataManager.BusObj)
                    
                    for entries in buses! {
                        let annotation = BusAnnotation()
                        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(entries.Longitude, entries.Latitude)
                        annotation.coordinate = location
                        annotation.title = entries.Registration
                        
                        annotation.subtitle = entries.Speed
                        self?.mapView.addAnnotation(annotation)
                    }
                }
            })
        }
    }
    
    func stopUpdatingPositions() {
        timer?.invalidate()
    }
    
    deinit {
        stopUpdatingPositions()
    }
    
}

extension FirstViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
            
        else if annotation is BusAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "bus-button")
            annotationView.tintColor = UIColor(red:0.00, green:0.66, blue:0.31, alpha:1.0)
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.canShowCallout = true
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
            
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(red:0.00, green:0.66, blue:0.31, alpha:1.0)
            renderer.lineWidth = 3
            return renderer
            
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
    //        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //            guard let annotation = view.annotation as? , let title = annotation.title else { return }
    //
    //            let alertController = UIAlertController(title: "Welcome to \(title)", message: "You've selected \(title)", preferredStyle: .alert)
    //            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    //            alertController.addAction(cancelAction)
    //            present(alertController, animated: true, completion: nil)
    //        }
}

