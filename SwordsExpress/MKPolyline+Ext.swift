//
//  MKPolyline+Ext.swift
//  SwordsExpress
//
//  Created by William O'Connor on 06/05/2018.
//  Copyright © 2018 William O'Connor. All rights reserved.
//

import Foundation
import MapKit

public extension MKPolyline {
    public var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: self.pointCount)
        
        self.getCoordinates(&coords, range: NSRange(location: 0, length: self.pointCount))
        
        return coords
    }
}
