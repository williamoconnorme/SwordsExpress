//
//  ScheduleInterfaceController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 18/08/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import WatchKit
import Foundation


class ScheduleInterfaceController: WKInterfaceController {

    
    var stops = ["Abbeyvale", "Swords Manor", "Boroimhe Maples"]
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        //scheduleTable.setNumberOfRows(stops.count, withRowType: "StopRow")
    }

//    override func willActivate() {
//        // This method is called when watch view controller is about to be visible to user
//        super.willActivate()
//    }
//
//    override func didDeactivate() {
//        // This method is called when watch view controller is no longer visible
//        super.didDeactivate()
//    }

}
