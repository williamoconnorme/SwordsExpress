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
                    let direction = entries[6].string!
                    
                    let bus = Bus(Registration: reg, Longitude: long, Latitude: lat, Time: time, Number: number, Speed: speed, Direction: direction)
                    self.BusObj.append(bus)
                    completionHandler(self.BusObj as AnyObject)
                }
            } // Loop ends
        }
        session.resume()
    }
    
    func updateLocations(completionHandler:@escaping (_ busObject:AnyObject)->Void) {
        print ("Dumping buses here")
        
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
                    let direction = entries[6].string!
                    
                    let bus = Bus(Registration: reg, Longitude: long, Latitude: lat, Time: time, Number: number, Speed: speed, Direction: direction)
                    self.BusObj.append(bus)
                    completionHandler(self.BusObj as AnyObject)
                }
            } // Loop ends
        }
        session.resume()

        
    }
}
