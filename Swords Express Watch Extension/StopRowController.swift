//
//  StopRowController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 18/08/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import WatchKit

class StopRowController: NSObject {

    @IBOutlet var fromLabel: WKInterfaceLabel!
    @IBOutlet var toLabel: WKInterfaceLabel!
    @IBOutlet var routeLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    
    let dataManager = DataManager()
    
    
    // 1
    var schedule: Schedule? {
        // 2
        didSet {
            // 3
            if let schedule = schedule {
                // 4
                
                fromLabel.setText(schedule.from)
                toLabel.setText(schedule.to)
                routeLabel.setText(schedule.stop)
                timeLabel.setText(schedule.time)
            }
        }
    }
}
