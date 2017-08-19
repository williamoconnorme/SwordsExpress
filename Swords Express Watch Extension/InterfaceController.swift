//
//  InterfaceController.swift
//  Swords Express Watch Extension
//
//  Created by William O'Connor on 18/08/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var scheduleTable: WKInterfaceTable!
    let dataManager = DataManager()
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        let tempFavsCity = ["Swords Manor", "Eden Quay", "Boroimhe Maples"]
        let tempFavsSwords = ["Swords Manor", "Airside Road"]
        
        for stop in tempFavsCity {
            
            let schedule = dataManager.getUpcomingBuses(stopNumber: stop, direction: "city")
            
            scheduleTable.setNumberOfRows((schedule?.count)!, withRowType: "StopRow")
            
            for index in 0..<scheduleTable.numberOfRows {
                if let controller = scheduleTable.rowController(at: index) as? StopRowController {
                    controller.schedule = schedule?[index]
                }
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
