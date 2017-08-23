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
    
    let domain: String = "http://www.swordsexpress.com/"
    var BusObj = [Bus]()
    var ScheObj = [Schedule]()
    
    func getLocations(completionHandler:@escaping (_ busObject:AnyObject)->Void) {
        let endpoint: String = "/latlong.php"
        let url: URL = URL(string: domain + endpoint)!
        
        let session = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print ("Data returned nil. Check getLocations func")
                return
            }
            
            let json = JSON(data: data)
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
                        direction = direction.uppercased()
                    }
                    
                    
                    let bus = Bus(Registration: reg, Longitude: long, Latitude: lat, Time: time, Number: number, Speed: speed, Direction: direction)
                    
                    
                    self.BusObj.append(bus)
                    completionHandler(self.BusObj as AnyObject)
                }
            } // Loop ends
        }
        session.resume()
    }
    
    func updateLocations(buses: [Bus], completionHandler:@escaping (_ busObject:AnyObject)->Void) {
        var fleet = buses
        // ayyyy should probably find a better way to update these buses
        
        let endpoint: String = "/latlong.php"
        let url: URL = URL(string: domain + endpoint)!
        
        let session = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print ("Data returned nil. Check getLocations func")
                return
            }
            
            let json = JSON(data: data)
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
                        direction = direction.uppercased()
                    }
                    
                    let bus = Bus(Registration: reg, Longitude: long, Latitude: lat, Time: time, Number: number, Speed: speed, Direction: direction)
                    self.BusObj.append(bus)
                    
                    completionHandler(self.BusObj as AnyObject)
                }
            } // Loop ends
        }
        session.resume()
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
                var json = JSON(data: data)
                
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
        
        var timetable = timetableParser(stopNumber: stopNumber, direction: direction)
        var from = ""
        var to = ""
        let time = getTime24Hour()
        
        let dir = direction
        for (route, arrivalTime) in timetable! {
            if arrivalTime.string! > time {
                if dir == "Swords" {
                    from = "City Centre"
                    to = "Swords"
                } else {
                    from = "Swords"
                    to = "City Centre"
                }
                let sched = Schedule(from: from, to: to, route: route, time: arrivalTime.string!, stop: stopNumber)
                self.ScheObj.append(sched)
                
            }
            // Sort by time
            ScheObj.sort(by: { $0.0.time < $0.1.time })
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
        } else {
            destination = "Swords"
        }
        var schedule = Schedule(from: stopNumber, to: destination, route: stopNumber, time: "12:34", stop: stopNumber)

        for (route, arrivalTime) in timetable! {
            schedule = Schedule(from: direction.capitalized, to: destination, route: route, time: arrivalTime.string!, stop: stopNumber)
            self.ScheObj.append(schedule)

        }
        // Sort by time
        ScheObj.sort(by: { $0.0.time < $0.1.time })
        return ScheObj
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

