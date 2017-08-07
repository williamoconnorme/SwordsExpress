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
    
    func timetableParser(stopNumber: String) -> JSON? {
        do {
            if let file = Bundle.main.url(forResource: "TimetableJSON", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = JSON(data: data)
                let day = getDay()
                
                if day == "Monday" || day == "Tuesday" || day ==  "Wednesday" || day == "Thursday" || day == "Friday" {
                    return json[stopNumber][0]
                }
                else if day == "Saturday" {
                    return json[stopNumber][1]
                } else if day == "Sunday" {
                    return json[stopNumber][2]
                } else {
                    print("Unable to determine what day is is.")
                }
                
            } else {
                print("No file found in project")
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    func getDay() -> String
    {
        // Set up date for retrieving bus times
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
    
    func getNextBus(stopNumber: String) {
        var timetable = timetableParser(stopNumber: stopNumber)
        //        timetable?.sorted(by: {$0["500"]})
        //        dump (timetable)
        
    }
    
}

