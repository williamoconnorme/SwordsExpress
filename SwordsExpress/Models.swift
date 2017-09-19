//
//  Models.swift
//  SwordsExpress
//
//  Created by William O'Connor on 30/07/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import Foundation

class Bus {
    let Registration: String
    let Longitude: Double
    let Latitude: Double
    let Time: String
    let Number: String // Change this once I know what it is
    let Speed: String
    let Direction: String
    
    init (Registration: String,
          Longitude: Double,
          Latitude: Double,
          Time: String,
          Number: String,
          Speed: String,
          Direction: String) {
        
        self.Registration = Registration
        self.Longitude = Longitude
        self.Latitude = Latitude
        self.Time = Time
        self.Number = Number
        self.Speed = Speed
        self.Direction = Direction
    }
}

class Schedule {
    
    let from: String
    let to: String
    let route: String
    let time: String
    let stop: String
    
    init (from: String,
          to: String,
          route: String,
          time: String,
          stop: String) {
        
        self.from = from
        self.to = to
        self.route = route
        self.time = time
        self.stop = stop
    }
}

class Stop: NSObject, NSCoding {
    
    let name: String
    let direction: String
    
    init (name: String,
          direction: String) {
        
        self.name = name
        self.direction = direction
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let name = decoder.decodeObject(forKey: "name") as? String,
            let direction = decoder.decodeObject(forKey: "direction") as? String
            else { return nil }
        
        self.init(
            name: name,
            direction: direction
        )
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.direction, forKey: "direction")
    }
    
}
// Override equatable so we can compare objects
func ==(lhs: Stop, rhs: Stop) -> Bool {
    return (lhs.name == rhs.name) && (lhs.direction == rhs.direction)
}
