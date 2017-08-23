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
            snapToRoad(wayPointArr: waypoints.waypoints500fromSwords)
            extendRoute(wayPointArr: waypoints.wayPointHelper)
            extendRoute(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 1: //501
            snapToRoad(wayPointArr: waypoints.waypoints501fromSwords)
            extendRoute(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 2: //502
            snapToRoad(wayPointArr: waypoints.waypoints502fromSwords)
            extendRoute(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 3: //503
            snapToRoad(wayPointArr: waypoints.waypoints502fromSwords) // Change THIS
            extendRoute(wayPointArr: waypoints.waypointsPearseGardaToMerrionSq)
        case 4: //504
            snapToRoad(wayPointArr: waypoints.waypoints504fromSwords)
        case 5: //505
            snapToRoad(wayPointArr: waypoints.waypoints505fromSwords)
            extendRoute(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 6: //507
            snapToRoad(wayPointArr: waypoints.waypoints505fromSwords) // Change THIS
        case 7: //500X
            snapToRoad(wayPointArr: waypoints.waypoints507fromSwords)
            extendRoute(wayPointArr: waypoints.wayPointHelper)
            extendRoute(wayPointArr: waypoints.waypointsIfscToEdenQ)
        case 8: //501X
            snapToRoad(wayPointArr: waypoints.waypoints507fromSwords)
            extendRoute(wayPointArr: waypoints.wayPointHelper)
            extendRoute(wayPointArr: waypoints.waypointsIfscToEdenQ)
        default:
            self.mapView.remove(polyline)
        }
    }
    
    
    
    let busStopsToCity =
        [
            [53.4596654, -6.2503624, 333, 1, "Abbeyvale"],
            [53.459984, -6.245307, 334, 2, "Swords Manor"],
            [53.4606895, -6.2413665, 339, 3, "Valley View"],
            [53.4625433, -6.2398851, 338, 4, "The Gallops"],
            [53.463878, -6.239549, 337, 5, "Lios Cian"],
            [53.4657815, -6.2397887, 336, 6, "Cianlea"],
            [53.468251, -6.2367971, 1234, 7, "Laurelton"],
            [53.4694079, -6.2308137, 340, 8, "Applewood Estate"],
            [53.4686893, -6.2279908, 341, 9, "Jugback Lane"],
            [53.4682362, -6.2209795, 342, 10, "Saint Colmcille's GFC"],
            [53.4650053, -6.2173297, 343, 11, "West Seatown"],
            [53.4622247, -6.2131752, 344, 12, "Seatown Road"],
            [53.4569384, -6.2124503, 345, 13, "Swords Bypass"],
            [53.454165, -6.215768, 582, 14, "Malahide Roundabout"],
            [53.454629, -6.2183, 347, 15, "Pavilions Shopping Centre"],
            [53.4558985, -6.2217432, 348, 16, "Dublin Road (Penneys)"],
            [53.4543519, -6.2243928, 583, 17, "Highfields"],
            [53.4526008, -6.2272095, 587, 18, "Ballintrane"],
            [53.4455748, -6.2352678, 351, 19, "Boroimhe Laurels"],
            [53.444665, -6.231174, 352, 20, "Boroimhe Maples"],
            [53.4449935, -6.2271727, 353, 21, "Airside Road"],
            [53.446006, -6.2243145, 354, 22, "Airside Central"],
            [53.443639, -6.2111045, 355, 23, "Holywell Distributor Road"],
            [53.4434736, -6.2093203, 356, 24, "M1 Drinan"],
            [53.3507872, -6.2259726, 357, 25, "East Wall Road"],
            [53.3474227, -6.2397389, 584, 26, "Convention Centre"],
            [53.3479217, -6.247108, 585, 27, "Seán O'Casey Bridge"],
            [53.348063, -6.256350, 586, 28, "Eden Quay"]
    ]
    
    let busStopsToSwords =
        [
            [53.3477969, -6.2584213, 555, 29, "Eden Quay"],
            [53.3482716, -6.2502319, 556, 30, "Ifsc"],
            [53.3481121, -6.2472811, 557, 31, "Custom House Quay"],
            [53.3477493, -6.2423821, 558, 32, "Custom House Quay"],
            [53.3473521, -6.2364198, 559, 33, "North Wall Quay"],
            [53.346875, -6.228919, 560, 34, "Point Depot"],
            [53.4434416, -6.2111721, 562, 35, "Holywell Distributor Road"],
            [53.446133, -6.222701, 563, 36, "Airside Central"],
            [53.444509, -6.231292, 564, 37, "Boroimhe Maples"],
            [53.445133, -6.235007, 565, 38, "Boroimhe Laurels"],
            [53.4521321, -6.2286058, 566, 39, "Ballintrane"],
            [53.4544301, -6.224466, 567, 40, "Highfields"],
            [53.45538, -6.222422, 568, 41, "Dublin Street"],
            [53.454339, -6.216293, 569, 42, "Malahide Roundabout"],
            [53.461677, -6.2134949, 570, 43, "Seatown Road"],
            [53.464877, -6.2169974, 571, 44, "West Seatown"],
            [53.4680775, -6.2215895, 572, 45, "Saint Colmcille's GFC"],
            [53.4684694, -6.2275828, 573, 46, "Jugback Lane"],
            [53.4695937, -6.2318054, 574, 47, "Applewood Estate"],
            [53.4683705, -6.2362437, 575, 48, "Laurelton"],
            [53.4666115, -6.2392209, 576, 49, "Cianlea"],
            [53.4656155, -6.2396175, 577, 50, "Ardcian"],
            [53.4641399, -6.239343, 578, 51, "Lios Cian"],
            [53.4616212, -6.2403112, 579, 52, "Valley View"],
            [53.4598859, -6.2417255, 580, 53, "Saint Cronan's South"],
            [53.459853, -6.245138, 581, 54, "Swords Manor"],
            [53.339029, -6.249886, 581, 55, "Merrion Square"]
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
            let stop = String(describing: entries[4])
            let timetableArr = dataManager.timetableParser(stopNumber: stop, direction: "city")
            //dump (timetableArr?[0])
            var bus = ""
            var holdTime = "24:00"
            for (route, arrivalTime) in timetableArr! {
                if arrivalTime.string! > dataManager.getTime24Hour() && arrivalTime.string! < holdTime {
                    
                    bus = "Next bus arrives at \(arrivalTime)"
                    holdTime = arrivalTime.string!
                    
                }
                
            }
            stopAnnotations.title = entries[4] as? String
            stopAnnotations.subtitle = bus
            
            self.mapView.addAnnotation(self.stopAnnotations)
        }
    }
    
    func addBusStopsToSwords() {
        for entries in busStopsToCity {
            
            self.stopAnnotations = StopAnnotations()
            self.stopAnnotations.coordinate = CLLocationCoordinate2DMake(entries[0] as! CLLocationDegrees, entries[1] as! CLLocationDegrees)
            //let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(entries[0], entries[1])
            //annotation.coordinate = location
            
            //let nextBus = Timetable.
            let stop = String(describing: entries[4])
            let timetableArr = dataManager.timetableParser(stopNumber: stop, direction: "swords")
            //dump (timetableArr?[0])
            var bus = ""
            var holdTime = "24:00"
            for (route, arrivalTime) in timetableArr! {
                if arrivalTime.string! > dataManager.getTime24Hour() && arrivalTime.string! < holdTime {
                    
                    bus = "Next bus arrives at \(arrivalTime)"
                    holdTime = arrivalTime.string!
                    
                }
                
            }
            stopAnnotations.title = entries[4] as? String
            stopAnnotations.subtitle = bus
            
            self.mapView.addAnnotation(self.stopAnnotations)
        }
    }
    
    func snapToRoad(wayPointArr: [Array<Double>]) {
        
        // Remove overlays
        mapView.removeOverlays(mapView.overlays)
        
        for (index, coordinate) in wayPointArr.enumerated() {
            
            if (index + 1 < wayPointArr.count) {
                
                let nextElement = wayPointArr[index + 1]
                
                // Start calculating directions
                let sourceCoordinates = CLLocationCoordinate2DMake(coordinate[0], coordinate[1])
                let destCoordinates = CLLocationCoordinate2DMake(nextElement[0], nextElement[1])
                
                let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates)
                let destPlacemark = MKPlacemark(coordinate: destCoordinates)
                
                let sourceItem = MKMapItem(placemark: sourcePlacemark)
                let destItem = MKMapItem(placemark: destPlacemark)
                
                let directionRequest = MKDirectionsRequest()
                directionRequest.source = sourceItem
                directionRequest.destination = destItem
                
                directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate(completionHandler: {
                    response, error in
                    
                    guard let response = response else {
                        if error != nil {
                            print("Something went wrong")
                            let alert = UIAlertController(title: "Uh oh!", message: "We could not make a suitable route to that location, using this mode of transport", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    let route = response.routes[0]
                    self.mapView.add(route.polyline, level: .aboveRoads)
                    
                })
                lastCoord = wayPointArr.last!
            }
        }
        
    }
    
    func extendRoute(wayPointArr: [Array<Double>]) {
        
        print ("Starting extension..")
        
        for (index, coordinate) in wayPointArr.enumerated() {
            if (index + 1 <= wayPointArr.count) {
                
                
                print ("Extending route...")
                
                //let nextElement = wayPointArr[index + 1]
                
                // Start calculating directions
                let sourceCoordinates = CLLocationCoordinate2DMake(lastCoord[0], lastCoord[1])
                let destCoordinates = CLLocationCoordinate2DMake(coordinate[0], coordinate[1])
                
                let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates)
                let destPlacemark = MKPlacemark(coordinate: destCoordinates)
                
                let sourceItem = MKMapItem(placemark: sourcePlacemark)
                let destItem = MKMapItem(placemark: destPlacemark)
                
                let directionRequest = MKDirectionsRequest()
                directionRequest.source = sourceItem
                directionRequest.destination = destItem
                
                directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate(completionHandler: {
                    response, error in
                    
                    guard let response = response else {
                        if error != nil {
                            print("Something went wrong")
                            let alert = UIAlertController(title: "Uh oh!", message: "We could not make a suitable route to that location, using this mode of transport", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    let route = response.routes[0]
                    self.mapView.add(route.polyline, level: .aboveRoads)
                    
                })
                lastCoord = wayPointArr.last!
            }
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
        //let location = locations[0]
        
        //        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        //        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        //Map.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dataManager.timetableParser(stopNumber: "1234", direction: <#String#>)
        
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
                    self.busAnnotations.subtitle = ("Travelling \(entries.Speed), heading \(entries.Direction)")
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    weak var timer: Timer?
    
    func startUpdatingPositions() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.dataManager.updateLocations(buses: (self?.dataManager.BusObj)!, completionHandler: { (BusObj) in
                //self?.mapView.removeAnnotations(busAnnotation)
                DispatchQueue.main.sync {
                    
                    let buses = (self?.dataManager.BusObj)
                    
                    
                    // Keep track of selected annotations
                    var selectedAnnotation = [MKAnnotation]()
                    if self?.mapView.selectedAnnotations != nil {
                        selectedAnnotation = (self?.mapView.selectedAnnotations)!
                    }
                    // Remove buses / Unfortunately this also removes selected annotations
                    for bus in (self?.mapView.annotations)! {
                        
                        if bus is BusAnnotation {
                            self?.mapView.selectAnnotation((bus), animated: false)
                            self?.mapView.removeAnnotations((self?.mapView.selectedAnnotations)!)
                        }
                    }
                    // Reselect previous selected annotation that were removed
                    if selectedAnnotation.count > 0 {
                        self?.mapView.selectAnnotation((selectedAnnotation[0]), animated: false)
                    }
                    
                    // Place buses back on map with updated information
                    for entries in buses! {
                        let annotation = BusAnnotation()
                        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(entries.Longitude, entries.Latitude)
                        annotation.coordinate = location
                        annotation.title = entries.Registration
                        
                        annotation.subtitle = ("Travelling \(entries.Speed), heading \(entries.Direction)")
                        
                        
                        
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
            
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "busAnnotationView") ?? MKAnnotationView()
            
            
            annotationView.image = UIImage(named: "bus-icon")
            annotationView.tintColor = UIColor(red:0.00, green:0.66, blue:0.31, alpha:1.0)
            annotationView.canShowCallout = true
            return annotationView
        }
        
        if annotation is StopAnnotations {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "stopAnnotationView") ?? MKAnnotationView()
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        //        if (view == mapView.dequeueReusableAnnotationView(withIdentifier: "stopAnnotationView")) {
        //            print ("Testing workins")
        //        } else {
        //            print ("Check did not work")
        //        }
        
        performSegue(withIdentifier: "mapToStopTable", sender: AnyObject.self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToStopTable" {
            let vc = segue.destination as! StopListViewController
            
            //let test = sender[self.stopAnnotations.coordinate.latitude]
            vc.PassedStopData = ["Swords Manor", "city"]
        }
    }
}
