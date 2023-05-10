//
//  DataManager.swift
//  SwordsExpress
//
//  Created by William O'Connor on 30/07/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import Foundation
import SwiftyJSON

class DataManager {
    
    let swordsExpressDomain: String = "https://www.swordsexpress.com"
    //let swordsExpressDomain: String = "http://williamoconnor.me" // For debugging.
    let fingalExpressDomain: String = "http://fingalexpress.com"
    
    var BusObj = [Bus]()
    var ScheObj = [Schedule]()
    var stopObj = [Stop]()
 
    func getBuses(buses: [Bus], completionHandler:@escaping (_ busObject:AnyObject)->Void) {
        _ = buses
        
        
        let seEndpoint: String = "/app/themes/swordsexpress/resources/assets/scripts/latlong.php"
        let feEndpoint: String = "/wp-content/themes/fingal/latlong.php"
        
        let seUrl: URL = URL(string: swordsExpressDomain + seEndpoint)!
        let feUrl: URL = URL(string: fingalExpressDomain + feEndpoint)!
        
        let session = URLSession.shared.dataTask(with: seUrl) { (data, response, error) in
            guard let data = data else {
                print ("Data returned nil. Check getLocations func")
                return
            }
            
            let json = try! JSON(data: data)
            let entries = json.array!
            
            self.BusObj.removeAll(keepingCapacity: true)
            
            for entries in entries {
                if entries[1] != "hidden" {
                    let reg = entries[0].string!
                    let long = Double(entries[1].string!)!
                    let lat = Double(entries[2].string!)!
                    let time = entries[3].string!
                    let number = entries[4].string!
                    let speed = entries[5].string!
                    var direction = entries[6].string!
                    
                    switch direction {
                    case "n":
                        direction = "North"
                    case "ne":
                        direction = "Northeast"
                    case "nw":
                        direction = "Northwest"
                    case "s":
                        direction = "South"
                    case "se":
                        direction = "Southeast"
                    case "sw":
                        direction = "Southwest"
                    case "e":
                        direction = "East"
                    case "w":
                        direction = "West"
                    default:
                        direction = "N/A"
                    }
                    
                    let bus = Bus(Registration: reg, Longitude: long, Latitude: lat, Time: time, Number: number, Speed: speed, Direction: direction)
                    self.BusObj.append(bus)
                    
                } else {
                    
                    let reg = entries[0].string!
                    let long = Double(0.0)
                    let lat = Double(0.0)
                    let time = "N/A"
                    let number = "0"
                    let speed = "0"
                    let direction = "N/A"
                    
                    let bus = Bus(Registration: reg, Longitude: long, Latitude: lat, Time: time, Number: number, Speed: speed, Direction: direction)
                    
                    
                    self.BusObj.append(bus)

                    
                }


            } // Loop ends

            completionHandler(self.BusObj as AnyObject)

        }
        
        if (1 != 1) {
            let session = URLSession.shared.dataTask(with: feUrl) { (data, response, error) in
                guard let data = data else {
                    print ("Data returned nil. Check getLocations func")
                    return
                }
                
                let json = try! JSON(data: data)
                let entries = json.array!
                
                for entries in entries {
                    if entries[1] != "hidden" {
                        let reg = entries[0].string!
                        let long = Double(entries[1].string!)!
                        let lat = Double(entries[2].string!)!
                        let time = entries[3].string!
                        let number = entries[4].string!
                        let speed = entries[5].string!
                        var direction = entries[6].string!
                        
                        
                        switch direction {
                        case "n":
                            direction = "North"
                        case "ne":
                            direction = "Northeast"
                        case "nw":
                            direction = "Northwest"
                        case "s":
                            direction = "South"
                        case "se":
                            direction = "Southeast"
                        case "sw":
                            direction = "Southwest"
                        case "e":
                            direction = "East"
                        case "w":
                            direction = "West"
                        default:
                            direction = "N/A"
                        }
                        
                        let bus = Bus(Registration: reg, Longitude: long, Latitude: lat, Time: time, Number: number, Speed: speed, Direction: direction)
                        
                        
                        self.BusObj.append(bus)
                    } else {
                        
                        let reg = entries[0].string!
                        let long = Double(0.0)
                        let lat = Double(0.0)
                        let time = "N/A"
                        let number = "0"
                        let speed = "0"
                        let direction = "N/A"
                        
                        let bus = Bus(Registration: reg, Longitude: long, Latitude: lat, Time: time, Number: number, Speed: speed, Direction: direction)
                        
                        
                        self.BusObj.append(bus)
                        dump(bus)
                        print ("BUSES DUMPED")
                        
                    }
                } // Loop ends
                completionHandler(self.BusObj as AnyObject)
            }
        }
        session.resume()
    }
    
    
 
    
    func updateBuses(buses: [Bus]) -> [Bus]? {
        _ = buses
        // ayyyy should probably find a better way to update these buses
        
        let seEndpoint: String = "/app/themes/swordsexpress/resources/assets/scripts/latlong.php"
        let feEndpoint: String = "/wp-content/themes/fingal/latlong.php"
        let seUrl: URL = URL(string: swordsExpressDomain + seEndpoint)!
        let feUrl: URL = URL(string: fingalExpressDomain + feEndpoint)!
        
        let session = URLSession.shared.dataTask(with: seUrl) { (data, response, error) in
            guard let data = data else {
                print ("Data returned nil. Check getLocations func")
                return
            }
            
            let json = try! JSON(data: data)
            let entries = json.array!
            
            self.BusObj.removeAll(keepingCapacity: true)
            
            for entries in entries {
                if entries[1] != "hidden" {
                    let reg = entries[0].string!
                    let long = Double(entries[1].string!)!
                    let lat = Double(entries[2].string!)!
                    let time = entries[3].string!
                    let number = entries[4].string!
                    let speed = entries[5].string!
                    var direction = entries[6].string!
                    
                    switch direction {
                    case "n":
                        direction = "North"
                    case "ne":
                        direction = "Northeast"
                    case "nw":
                        direction = "Northwest"
                    case "s":
                        direction = "South"
                    case "se":
                        direction = "Southeast"
                    case "sw":
                        direction = "Southwest"
                    case "e":
                        direction = "East"
                    case "w":
                        direction = "West"
                    default:
                        direction = "N/A"
                    }
                    
                    let bus = Bus(Registration: reg, Longitude: long, Latitude: lat, Time: time, Number: number, Speed: speed, Direction: direction)
                    self.BusObj.append(bus)
                    
                    //completionHandler(self.BusObj as AnyObject)
                } else {
                    
                    let reg = entries[0].string!
                    let long = Double(0.0)
                    let lat = Double(0.0)
                    let time = "N/A"
                    let number = "0"
                    let speed = "0"
                    let direction = "N/A"
                    
                    let bus = Bus(Registration: reg, Longitude: long, Latitude: lat, Time: time, Number: number, Speed: speed, Direction: direction)
                    
                    
                    self.BusObj.append(bus)
                    //completionHandler(self.BusObj as AnyObject)
                    
                }
            } // Loop ends
        }
        session.resume()
        return BusObj
    }
    
    func timetableParser(stopNumber: String, direction: String) -> JSON? {
        do {
            
            let day = getDay()
            var timetable = "TimetableJSON" // Changes in if statement
            let busDirection = direction
            
            if day == "Monday" || day == "Tuesday" || day ==  "Wednesday" || day == "Thursday" || day == "Friday" {
                if busDirection == "city" {
                    timetable = "SwordsCityMonFri"
                } else {
                    timetable = "CitySwordsMonFri"
                }
            }
            else if day == "Saturday" {
                if busDirection == "city" {
                    timetable = "SwordsCitySat"
                } else {
                    timetable = "CitySwordsSat"
                }
            } else if day == "Sunday" {
                if busDirection == "city" {
                    timetable = "SwordsCitySun"
                } else {
                    timetable = "CitySwordsSun"
                }
            } else {
                print("Unable to determine what day is is.")
                return nil
            }
            
            
            if let file = Bundle.main.url(forResource: timetable, withExtension: "json") {
                let data = try Data(contentsOf: file)
                var json = try! JSON(data: data)
                
                return json[stopNumber]
                
            } else {
                print("Unable to find \(timetable) in project")
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    
    func getUpcomingBuses(stopNumber: String, direction: String) -> [Schedule]? {
        
        let timetable = timetableParser(stopNumber: stopNumber, direction: direction)
        var from = ""
        var to = ""
        let time = getTime24Hour()
        
        
        let dir = direction
        for (arrivalTime, route) in timetable! {
            if arrivalTime > time {
                if dir == "Swords" {
                    from = "City Centre"
                    to = "Swords"
                } else {
                    from = "Swords"
                    to = "City Centre"
                }
                let sched = Schedule(from: from, to: to, route: route.string!, time: arrivalTime, stop: stopNumber)
                self.ScheObj.append(sched)
                
            }
            // Sort by time
            ScheObj.sort(by: { $0.time < $1.time })
            return ScheObj
        }
        print ("func getupcomingbuses Returned nil")
        return nil
    }
    
    func getFullTimetable(stopNumber: String, direction: String) -> [Schedule]? {
        
        let timetable = timetableParser(stopNumber: stopNumber, direction: direction)
        let destination: String
        
        if direction == "city" {
            destination = "City Centre"
        } else if direction == "swords" {
            destination = "Swords"
        } else {
            print ("direction NOT SET")
            destination = "Swords"
        }

        for (arrivalTime, route) in timetable! {
            let schedule = Schedule(from: direction.capitalized, to: destination, route: route.string!, time: arrivalTime, stop: stopNumber)
            self.ScheObj.append(schedule)

        }
        // Sort by time
        ScheObj.sort(by: { $0.time < $1.time })
        return ScheObj
    }
    
    func extractNextArrivalTime(stopNumber: String, direction: String) -> [Schedule]? {
        
        let timetable = getFullTimetable(stopNumber: stopNumber, direction: direction)

        let currentTime = getTime24Hour()
        
        for item in timetable! {
            if currentTime > item.time {
                let object = Schedule(from: item.from, to: item.to, route: item.route, time: item.time, stop: item.stop)
                self.ScheObj = [object]
                return ScheObj
            }
        }
        print ("Returned nil when extracting next arrival time")
        return nil
    
    
    }
    
    
    func getDay() -> String
    {
        // Gets current day as string
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEEE"
        let currentDateString: String = dateFormatter.string(from: date)
        return currentDateString
    }
    func getTime24Hour() -> String {
        // Time for comparing against bus times
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm"
        let currentTimeString: String = dateFormatter.string(from: date)
        return currentTimeString
    }
    
}


