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
    let timetable = Timetable()
    
    var busAnnotations = MKPointAnnotation()
    var stopAnnotations = MKPointAnnotation()
    
    
    
    // Segment controller for changing annotations
    @IBAction func ShowHideAnnotations(_ sender: Any) {
        
        switch SegController.selectedSegmentIndex {
        case 0:
            // Remove Annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.RouteSegControl.selectedSegmentIndex = -1
            
            
            
            addBusStopsToCity()
        case 1:
            // Remove Annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.RouteSegControl.selectedSegmentIndex = -1
            addBusStopsToSwords()
        default:
            // Remove Annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }
    
    @IBAction func ShowHidePolyline(_ sender: Any) {
        switch RouteSegControl.selectedSegmentIndex {
        case 0: //500
            addPolyline(wayPointArr: waypoints.waypoints500fromSwords)
            appendPolyLine(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 1: //501
            addPolyline(wayPointArr: waypoints.waypoints501fromSwords)
            appendPolyLine(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 2: //502
            addPolyline(wayPointArr: waypoints.waypoints502fromSwords)
            appendPolyLine(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 3: //503
            addPolyline(wayPointArr: waypoints.waypoints502fromSwords) // Change THIS
            appendPolyLine(wayPointArr: waypoints.waypointsPearseGardaToMerrionSq)
        case 4: //504
            addPolyline(wayPointArr: waypoints.waypoints504fromSwords)
        case 5: //505
            addPolyline(wayPointArr: waypoints.waypoints505fromSwords)
            appendPolyLine(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 6: //506
            addPolyline(wayPointArr: waypoints.waypoints505fromSwords) // Change THIS
        case 7: //507
            addPolyline(wayPointArr: waypoints.waypoints507fromSwords)
            appendPolyLine(wayPointArr: waypoints.waypointsIfscToEdenQ)
        default:
            self.mapView.remove(polyline)
        }
    }
    
    
    
    let busStopsToCity =
        [
            [53.4596654, -6.2503624, 333, 1, "ABBEYVALE"],
            [53.459984, -6.245307, 334, 2, "SWORDS MANOR"],
            [53.4606895, -6.2413665, 339, 3, "VALLEY VIEW"],
            [53.4625433, -6.2398851, 338, 4, "THE GALLOPS"],
            [53.463878, -6.239549, 337, 5, "LIOS CIAN"],
            [53.4657815, -6.2397887, 336, 6, "CIANLEA"],
            [53.468251, -6.2367971, 1234, 7, "LAURELTON"],
            [53.4694079, -6.2308137, 340, 8, "APPLEWOOD ESTATE"],
            [53.4686893, -6.2279908, 341, 9, "JUGBACK LANE"],
            [53.4682362, -6.2209795, 342, 10, "SAINT COLMCILLE'S GFC, SWORDS"],
            [53.4650053, -6.2173297, 343, 11, "WEST SEATOWN"],
            [53.4622247, -6.2131752, 344, 12, "SEATOWN ROAD"],
            [53.4569384, -6.2124503, 345, 13, "SWORDS BYPASS"],
            [53.454165, -6.215768, 582, 14, "MALAHIDE ROUNDABOUT, SWORDS"],
            [53.454629, -6.2183, 347, 15, "PAVILIONS SHOPPING CENTRE"],
            [53.4558985, -6.2217432, 348, 16, "Swords Main Street (Penneys)"],
            [53.4543519, -6.2243928, 583, 17, "HIGHFIELDS"],
            [53.4526008, -6.2272095, 587, 18, "BALLINTRANE"],
            [53.4455748, -6.2352678, 351, 19, "BOROIMHE LAURELS"],
            [53.444665, -6.231174, 352, 20, "BOROIMHE MAPLES"],
            [53.4449935, -6.2271727, 353, 21, "AIRSIDE ROAD"],
            [53.446006, -6.2243145, 354, 22, "AIRSIDE CENTRAL"],
            [53.443639, -6.2111045, 355, 23, "HOLYWELL DISTRIBUTOR ROAD"],
            [53.4434736, -6.2093203, 356, 24, "M1 DRINAN"],
            [53.3507872, -6.2259726, 357, 25, "EAST WALL ROAD"],
            [53.3474227, -6.2397389, 584, 26, "CONVENTION CENTRE"],
            [53.3479217, -6.247108, 585, 27, "SEAN O'CASEY PEDESTRIAN BRIDGE"],
            [53.348063, -6.256350, 586, 28, "EDEN QUAY"]
    ]
    
    let busStopsToSwords =
        [
            [53.3477969, -6.2584213, 555, 29, "EDEN QUAY"],
            [53.3482716, -6.2502319, 556, 30, "IFSC"],
            [53.3481121, -6.2472811, 557, 31, "CUSTOM HOUSE QUAY"],
            [53.3477493, -6.2423821, 558, 32, "CUSTOM HOUSE QUAY"],
            [53.3473521, -6.2364198, 559, 33, "NORTH WALL QUAY"],
            [53.346875, -6.228919, 560, 34, "POINT DEPOT"],
            [53.4434416, -6.2111721, 562, 35, "HOLYWELL DISTRIBUTOR ROAD"],
            [53.446133, -6.222701, 563, 36, "AIRSIDE CENTRAL"],
            [53.444509, -6.231292, 564, 37, "BOROIMHE MAPLES"],
            [53.445133, -6.235007, 565, 38, "BOROIMHE LAURELS"],
            [53.4521321, -6.2286058, 566, 39, "BALLINTRANE"],
            [53.4544301, -6.224466, 567, 40, "HIGHFIELDS"],
            [53.45538, -6.222422, 568, 41, "DUBLIN STREET"],
            [53.454339, -6.216293, 569, 42, "MALAHIDE ROUNDABOUT"],
            [53.461677, -6.2134949, 570, 43, "SEATOWN ROAD"],
            [53.464877, -6.2169974, 571, 44, "WEST SEATOWN"],
            [53.4680775, -6.2215895, 572, 45, "SAINT COLMCILLE'S GFC, SWORDS"],
            [53.4684694, -6.2275828, 573, 46, "JUGBACK LANE"],
            [53.4695937, -6.2318054, 574, 47, "APPLEWOOD ESTATE"],
            [53.4683705, -6.2362437, 575, 48, "LAURELTON"],
            [53.4666115, -6.2392209, 576, 49, "CIANLEA"],
            [53.4656155, -6.2396175, 577, 50, "ARDCIAN"],
            [53.4641399, -6.239343, 578, 51, "LIOS CIAN"],
            [53.4616212, -6.2403112, 579, 52, "VALLEY VIEW"],
            [53.4598859, -6.2417255, 580, 53, "SAINT CRONAN'S SOUTH"],
            [53.459853, -6.245138, 581, 54, "SWORDS MANOR"],
            [53.339029, -6.249886, 581, 55, "MERRION SQUARE"]
    ]
    
    func addPolyline(wayPointArr: [Array<Double>]) {
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
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
            
            self.stopAnnotations = StopAnnotations()
            self.stopAnnotations.coordinate = CLLocationCoordinate2DMake(entries[0] as! CLLocationDegrees, entries[1] as! CLLocationDegrees)
            //let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(entries[0], entries[1])
            //annotation.coordinate = location
            
            //let nextBus = Timetable.
            stopAnnotations.title = entries[4] as! String
            stopAnnotations.subtitle = "Next bus: "
            
            self.mapView.addAnnotation(self.stopAnnotations)
        }
    }
    
    func addBusStopsToSwords() {
        
        for entries in busStopsToSwords {
            self.stopAnnotations = StopAnnotations()
            self.stopAnnotations.coordinate = CLLocationCoordinate2DMake(entries[0] as! CLLocationDegrees, entries[1] as! CLLocationDegrees)
            
            stopAnnotations.title = entries[4] as! String
            stopAnnotations.subtitle = "Next bus: "
            
            self.mapView.addAnnotation(self.stopAnnotations)
        }
    }
    
    func snapToRoad() {
        let directionRequest = MKDirectionsRequest()
        
        for item in waypoints.waypoints500fromCity {
            //   directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: item[0], item[0])
            
        }
    }
    
    class BusAnnotation : MKPointAnnotation {
        var pinTintColor: UIColor?
    }
    
    class StopAnnotations : MKPointAnnotation {
        
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
            
            let buses = (self.dataManager.BusObj)
            DispatchQueue.main.sync {
                
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
        //mapView.removeAnnotations(Bus)
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
        
        dataManager.timetableParser(stopNumber: "1234")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    weak var timer: Timer?
    
    func startUpdatingPositions() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.dataManager.updateLocations(buses: (self?.dataManager.BusObj)!, completionHandler: { (BusObj) in
                //self?.mapView.removeAnnotations(busAnnotation)
                DispatchQueue.main.sync {
                    
                    let buses = (self?.dataManager.BusObj)
                    
                    // Remove buses
                    for bus in (self?.mapView.annotations)! {
                        
                        if bus is BusAnnotation {
                            self?.mapView.selectAnnotation((bus), animated: false)
                            self?.mapView.removeAnnotations((self?.mapView.selectedAnnotations)!)
                        }
                        
                    }
                    
                    
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
            
            
            annotationView.image = UIImage(named: "bus-icon")
            annotationView.tintColor = UIColor(red:0.00, green:0.66, blue:0.31, alpha:1.0)
            annotationView.canShowCallout = true
            return annotationView
        }
        
        if annotation is StopAnnotations {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "stop-icon")
            annotationView.canShowCallout = true
            annotationView.tintColor = UIColor(red:0.00, green:0.66, blue:0.31, alpha:1.0)
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
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
