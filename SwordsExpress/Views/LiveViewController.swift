//
//  LiveViewController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 30/07/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit
import MapKit
import RevealingSplashView

private let busPin = MKPointAnnotation()
private let annotations = MKPointAnnotation()


class LiveViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var SegController: UISegmentedControl!
    @IBOutlet weak var RouteSegControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    
    let dataManager = DataManager()
    let manager = CLLocationManager()
    var polyline = MKPolyline()
    let routes = Routes()
    var lastCoord = [Double]()
    let stops = Stops()
    var busesArr: [MKPointAnnotation] = []
    var service: Bool = false
    
    var busAnnotations: MKPointAnnotation = MKPointAnnotation()
    var stopAnnotations = MKPointAnnotation()
    
    // Segment controller for changing annotations
    @IBAction func ShowHideAnnotations(_ sender: Any) {
        
        //SegController.selectedSegmentTintColor = UIColor.
        
        switch SegController.selectedSegmentIndex {
        case 0:
            // Remove Annotations
            self.mapView.annotations.forEach {
                if ($0 is StopAnnotations) {
                    self.mapView.removeAnnotation($0)
                }
            }
            // Add bus stops
            addBusStops(direction: "city")
            
            // Remove overlays
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
            
            // Reset RouteSegControl
            self.RouteSegControl.selectedSegmentIndex = -1
            
            self.RouteSegControl.removeAllSegments()
            
            self.RouteSegControl.insertSegment(withTitle: "500", at: 0, animated: false)
            self.RouteSegControl.insertSegment(withTitle: "501", at: 1, animated: false)
            self.RouteSegControl.insertSegment(withTitle: "502", at: 2, animated: false)
            self.RouteSegControl.insertSegment(withTitle: "503", at: 3, animated: false)
            self.RouteSegControl.insertSegment(withTitle: "504", at: 4, animated: false)
            self.RouteSegControl.insertSegment(withTitle: "505", at: 5, animated: false)
            self.RouteSegControl.insertSegment(withTitle: "507", at: 6, animated: true)
            self.RouteSegControl.insertSegment(withTitle: "500X", at: 7, animated: true)
            self.RouteSegControl.insertSegment(withTitle: "501X", at: 8, animated: true)
            
            
        case 1:
            // Remove Annotations
            self.mapView.annotations.forEach {
                if ($0 is StopAnnotations) {
                    self.mapView.removeAnnotation($0)
                }
            }
            // Add bus stops
            addBusStops(direction: "swords")
            
            // Remove overlays
            let overlays = mapView.overlays
            mapView.removeOverlays(overlays)
            
            // Reset RouteSegControl
            self.RouteSegControl.selectedSegmentIndex = -1
            
            // Set RouteSegControl values
            self.RouteSegControl.removeAllSegments()
            
            self.RouteSegControl.insertSegment(withTitle: "500", at: 0, animated: true)
            self.RouteSegControl.insertSegment(withTitle: "503", at: 1, animated: true)
            self.RouteSegControl.insertSegment(withTitle: "506", at: 2, animated: true)
            self.RouteSegControl.insertSegment(withTitle: "500X", at: 3, animated: true)
            self.RouteSegControl.insertSegment(withTitle: "501X", at: 4, animated: true)
            self.RouteSegControl.insertSegment(withTitle: "505X", at: 5, animated: true)
            
        default:
            // Remove Annotations
            self.mapView.annotations.forEach {
                if ($0 is StopAnnotations) {
                    self.mapView.removeAnnotation($0)
                }
                
            }
        }
    }
    
    @IBAction func ShowHidePolyline(_ sender: Any) {
        // Remove overlays from Map
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        switch RouteSegControl.selectedSegmentIndex {
        case 0: //500
            
            if self.SegController.selectedSegmentIndex == 0 {
                addPolyline(wayPointArr: routes.SwordsManorStart)
                addPolyline(wayPointArr: routes.waypoints500fromSwords)
                addPolyline(wayPointArr: routes.waypointsPortTunnel3Arena)
                addPolyline(wayPointArr: routes.waypoint3ArenaQuays)
            } else if self.SegController.selectedSegmentIndex == 1 {
                addPolyline(wayPointArr: routes.waypointsEdenQuayStart)
                addPolyline(wayPointArr: routes.waypoints500fromCity)
                addPolyline(wayPointArr: routes.waypointsSwordsManorFinish)
            }
        case 1: //501
            if self.SegController.selectedSegmentIndex == 0 {
                addPolyline(wayPointArr: routes.PavilionsStart)
                addPolyline(wayPointArr: routes.waypoints501fromSwords)
                addPolyline(wayPointArr: routes.waypoint3ArenaQuays)
            } else if self.SegController.selectedSegmentIndex == 1 {
                addPolyline(wayPointArr: routes.waypointsMerrionSqToPearseSt)
                addPolyline(wayPointArr: routes.waypoints500fromCity)
                addPolyline(wayPointArr: routes.waypointsSwordsManorFinish)
            }
        case 2: //502
            
            if self.SegController.selectedSegmentIndex == 0 {
                
                addPolyline(wayPointArr: routes.HighfieldStart)
                addPolyline(wayPointArr: routes.waypoints501fromSwords)
                addPolyline(wayPointArr: routes.waypoint3ArenaQuays)
                
                
            } else if self.SegController.selectedSegmentIndex == 1 {
                addPolyline(wayPointArr: routes.waypointsEdenQuayStart)
                addPolyline(wayPointArr: routes.waypoints506fromCity)
                addPolyline(wayPointArr: routes.waypointsSwordsManorFinish)
            }
            
        case 3: //503
            if self.SegController.selectedSegmentIndex == 0 {
                
                addPolyline(wayPointArr: routes.SwordsManorStart)
                addPolyline(wayPointArr: routes.waypoints500fromSwords)
                addPolyline(wayPointArr: routes.waypointsPortTunnel3Arena)
                addPolyline(wayPointArr: routes.waypointsPearseGardaToMerrionSq)
            } else if self.SegController.selectedSegmentIndex == 1 {
                addPolyline(wayPointArr: routes.waypointsEdenQuayStart)
                addPolyline(wayPointArr: routes.waypoints500XfromCity)
                addPolyline(wayPointArr: routes.waypointsSwordsManorFinish)
            }
        case 4: //504
            if self.SegController.selectedSegmentIndex == 0 {
                addPolyline(wayPointArr: routes.waypoints504fromSwords)
                addPolyline(wayPointArr: routes.waypointsPortTunnel3Arena)
            } else if self.SegController.selectedSegmentIndex == 1 {
                addPolyline(wayPointArr: routes.waypointsEdenQuayStart)
                addPolyline(wayPointArr: routes.waypoints501XfromCity)
                
            }
        case 5: //505
            if self.SegController.selectedSegmentIndex == 0 {
                
                addPolyline(wayPointArr: routes.HighfieldStart)
                addPolyline(wayPointArr: routes.waypointsRiverValleyLoop)
                addPolyline(wayPointArr: routes.waypoints505fromSwords)
                addPolyline(wayPointArr: routes.waypoint3ArenaQuays)
                
            } else if self.SegController.selectedSegmentIndex == 1 {
                addPolyline(wayPointArr: routes.waypointsEdenQuayStart)
                addPolyline(wayPointArr: routes.waypoints505XfromCity)
            }
        case 6: //507
            addPolyline(wayPointArr: routes.SwordsManorStart)
            addPolyline(wayPointArr: routes.waypoints507fromSwords)
            addPolyline(wayPointArr: routes.waypointsPortTunnel3Arena)
            addPolyline(wayPointArr: routes.waypoint3ArenaQuays)
        case 7: //500X
            addPolyline(wayPointArr: routes.SwordsManorStart)
            addPolyline(wayPointArr: routes.waypoints500XfromSwords)
            addPolyline(wayPointArr: routes.waypoint3ArenaQuays)
        case 8: //501X
            addPolyline(wayPointArr: routes.PavilionsStart)
            addPolyline(wayPointArr: routes.PavilionsExtensions501X)
            addPolyline(wayPointArr: routes.waypoints501XfromSwords)
            addPolyline(wayPointArr: routes.waypoint3ArenaQuays)
            
        default:
            // Remove overlays
            mapView.removeOverlays(overlays)
        }
    }
    
    func addPolyline(wayPointArr: [Array<Double>]) {
        
        let waypoint = wayPointArr.map { CLLocationCoordinate2DMake($0[0], $0[1]) }
        lastCoord = wayPointArr.last!
        polyline = MKPolyline(coordinates: waypoint, count: waypoint.count)
        mapView?.addOverlay(polyline)
        
        
    }
    
    func appendPolyLine(wayPointArr: [Array<Double>]) {
        var connectedWaypoint = wayPointArr
        connectedWaypoint.insert(lastCoord, at: 0)
        let waypoint = connectedWaypoint.map { CLLocationCoordinate2DMake($0[0], $0[1]) }
        polyline = MKPolyline(coordinates: waypoint, count: waypoint.count)
        mapView?.addOverlay(polyline)
    }
    
    func addBusStops(direction: String) {
        
        var stopAnn = stops.toSwords
        
        if direction == "city" {
            stopAnn = stops.toCity
        } else {
            stopAnn = stops.toSwords
        }
        
        for entries in stopAnn {
            
            self.stopAnnotations = StopAnnotations()
            self.stopAnnotations.coordinate = CLLocationCoordinate2DMake(entries[0] as! CLLocationDegrees, entries[1] as! CLLocationDegrees)
            
            let stop = String(describing: entries[4])
            let timetableArr = dataManager.timetableParser(stopNumber: stop, direction: direction)
            var bus = ""
            var holdTime = "24:00"
            for (arrivalTime, route) in timetableArr! {
                if arrivalTime > dataManager.getTime24Hour() && arrivalTime < holdTime {
                    
                    bus = "Next bus arrives at \(arrivalTime) (\(route))"
                    holdTime = arrivalTime
                    
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
                
                let directionRequest = MKDirections.Request()
                directionRequest.source = sourceItem
                directionRequest.destination = destItem
                
                directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate(completionHandler: {
                    response, error in
                    
                    guard let response = response else {
                        if error != nil {
                            let alert = UIAlertController(title: "Oh no!", message: "The route cannot be shown at this time. Please try again later.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    let route = response.routes[0]
                    
                    
                    for each in (route.polyline.coordinates) {
                        print("[\(each.latitude), \(each.longitude)],")
                    }
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    print ("// TEST")
                    print ("")
                })
                lastCoord = wayPointArr.last!
            }
        }
        
    }
    
    
    func snapToRoadExclude(wayPointArr: [Array<Double>]) {
        
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
                
                let directionRequest = MKDirections.Request()
                directionRequest.source = sourceItem
                directionRequest.destination = destItem
                
                directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate(completionHandler: {
                    response, error in
                    
                    guard let response = response else {
                        if error != nil {
                            let alert = UIAlertController(title: "Oh no!", message: "The route cannot be shown at this time. Please try again later.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    let route = response.routes[0]
                    
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                })
                lastCoord = wayPointArr.last!
            }
        }
        
    }
    
    func extendRoute(wayPointArr: [Array<Double>]) {
        
        
        for (index, coordinate) in wayPointArr.enumerated() {
            if (index + 1 <= wayPointArr.count) {
                
                // Start calculating directions
                let sourceCoordinates = CLLocationCoordinate2DMake(lastCoord[0], lastCoord[1])
                let destCoordinates = CLLocationCoordinate2DMake(coordinate[0], coordinate[1])
                
                let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates)
                let destPlacemark = MKPlacemark(coordinate: destCoordinates)
                
                let sourceItem = MKMapItem(placemark: sourcePlacemark)
                let destItem = MKMapItem(placemark: destPlacemark)
                
                let directionRequest = MKDirections.Request()
                directionRequest.source = sourceItem
                directionRequest.destination = destItem
                
                directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate(completionHandler: {
                    response, error in
                    
                    guard let response = response else {
                        if error != nil {
                            let alert = UIAlertController(title: "Uh oh!", message: "The route cannot be shown at this time. Please try again later.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    let route = response.routes[0]
                    print ("TEST1")
                    print(route.polyline.coordinates) // Get coordinates from MKRoute
                    print ("TEST2")
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                })
                lastCoord = wayPointArr.last!
            }
        }
        
    }
    
    
    func exludeExtendRoute(wayPointArr: [Array<Double>]) {
        
        
        for (index, coordinate) in wayPointArr.enumerated() {
            if (index + 1 <= wayPointArr.count) {
                
                // Start calculating directions
                let sourceCoordinates = CLLocationCoordinate2DMake(lastCoord[0], lastCoord[1])
                let destCoordinates = CLLocationCoordinate2DMake(coordinate[0], coordinate[1])
                
                let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates)
                let destPlacemark = MKPlacemark(coordinate: destCoordinates)
                
                let sourceItem = MKMapItem(placemark: sourcePlacemark)
                let destItem = MKMapItem(placemark: destPlacemark)
                
                let directionRequest = MKDirections.Request()
                directionRequest.source = sourceItem
                directionRequest.destination = destItem
                
                directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate(completionHandler: {
                    response, error in
                    
                    guard let response = response else {
                        if error != nil {
                            let alert = UIAlertController(title: "Uh oh!", message: "The route cannot be shown at this time. Please try again later.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    
                    let route = response.routes[0]
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                })
                lastCoord = wayPointArr.last!
            }
        }
        
    }
    
    class BusAnnotation : MKPointAnnotation {
        var tag: String?
    }
    
    class PinAnnotation : NSObject, MKAnnotation {
        private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        var coordinate: CLLocationCoordinate2D {
            get {
                return coord
            }
        }
        
        var title: String? = ""
        var subtitle: String? = ""
        
        func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
            self.coord = newCoordinate
        }
    }
    
    class StopAnnotations : MKPointAnnotation {
        
        var pinTintColor: UIColor?
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //        let location = locations[0]
        //
        //        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        //        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        //        mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            mapView.mapType = .mutedStandard
        }
        
        //Initialize a revealing Splash with with the iconImage, the initial size and the background color
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "stop-sign-transparent")!,iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: UIColor(red:0.11, green:0.56, blue:0.95, alpha:1.0))
        revealingSplashView.backgroundColor = UIColor(displayP3Red:0.00, green:0.67, blue:0.31, alpha:1.0)
        revealingSplashView.delay = 1
        revealingSplashView.duration = 2
        //revealingSplashView.iconInitialSize = CGSize(width: 272, height: 272)
        self.tabBarController?.tabBar.isHidden = true
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(revealingSplashView)
        
        //Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)
        
        //Starts animation
        revealingSplashView.startAnimation(){
            self.tabBarController?.tabBar.isHidden = false
        }
        
        // Plot bus stops to city by default
        addBusStops(direction: "city")
        // Plot buses for first time
        dataManager.getBuses(buses: (self.dataManager.BusObj), completionHandler: { (BusObj) in
            
            let buses = (self.dataManager.BusObj)
            DispatchQueue.main.sync {
                for entries in buses {
                    
                    self.busAnnotations = BusAnnotation()
                    let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(entries.Longitude, entries.Latitude)
                    self.busAnnotations.coordinate = location
                    self.busAnnotations.title = entries.Registration
                    self.busAnnotations.subtitle = ("Travelling \(entries.Direction) at \(entries.Speed)")
                    self.mapView.addAnnotation(self.busAnnotations)
                    self.busesArr.append(self.busAnnotations)
                }
                
                // Show announcement if there are no buses running.
                
                for each in self.dataManager.BusObj {
                    if each.Direction != "N/A" {
                        self.service = true
                    }
                }
                
                if self.service == false {
                    
                    
                    //let announcement = Announcement(title: "Service Announcement", subtitle: "There are no running buses at this time.", image: UIImage(named: "avatar"), duration: 20.0)
                    //Whisper.show(shout: announcement, to: self, completion: {
                    //})
                }
            }
        })
        
        //Update bus locations test
        startUpdatingPositions()
        
        // User Location
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//        manager.requestWhenInUseAuthorization()
//        manager.startUpdatingLocation()
        
        // Zoom in on Swords
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.4557, longitude: -6.2197), span: span)
            self.mapView.setRegion(region, animated: true)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    weak var timer: Timer?
    
    func startUpdatingPositions() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            
            
            let updatedLocations = self?.dataManager.updateBuses(buses: (self?.dataManager.BusObj)!)
            
            DispatchQueue.main.async {
                
                //  Place buses back on map with updated information
                for entries in updatedLocations! {
                    
                    UIView.animate(withDuration: 5, animations: {
                        
                        for each in (self?.busesArr)! where each.title == entries.Registration && entries.Direction != "N/A"  {
                            let updatedPosition = CLLocationCoordinate2D(latitude: entries.Longitude, longitude: entries.Latitude)
                            
                            each.coordinate = updatedPosition
                            each.subtitle = "Travelling \(entries.Direction) at \(entries.Speed)"
                        }
                        
                    }, completion: nil)
                }
            }
        }
    }
    
    func stopUpdatingPositions() {
        timer?.invalidate()
    }
    
    deinit {
        stopUpdatingPositions()
    }
    
}

extension LiveViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
            
        else if annotation is BusAnnotation {
            
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "busAnnotationView") ?? MKAnnotationView()
            
            annotationView.image = UIImage(named: "bus-icon")
            annotationView.tintColor = UIColor(displayP3Red:0.00, green:0.67, blue:0.31, alpha:1.0)
            annotationView.canShowCallout = true
            return annotationView
        }
        
        if annotation is StopAnnotations {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "stopAnnotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "stop-icon")
            annotationView.canShowCallout = true
            annotationView.tintColor = UIColor(displayP3Red:0.00, green:0.67, blue:0.31, alpha:1.0)
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
            renderer.strokeColor = UIColor(displayP3Red:0.00, green:0.67, blue:0.31, alpha:1.0)
            renderer.lineWidth = 3
            renderer.lineDashPhase = 2
            renderer.lineDashPattern = [NSNumber(value:1), NSNumber(value:5)]
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
        performSegue(withIdentifier: "mapToStopTable", sender: view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToStopTable" {
            
            let navController = segue.destination as! UINavigationController
            let vc = navController.topViewController as! StopListViewController
            let stop = self.mapView.selectedAnnotations[0].title
            let direc = self.SegController.selectedSegmentIndex
            var direction: String
            
            if direc == 0 {
                direction = "city"
            } else {
                direction = "swords"
            }
            
            vc.PassedStopData = [stop!!, direction]
        }
    }
}
