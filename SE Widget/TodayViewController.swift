//
//  TodayViewController.swift
//  SE Widget
//
//  Created by William O'Connor on 18/08/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var textLabel: UILabel!
    
    let dataManager = DataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        
        if UserDefaults.standard.object(forKey: "favourites") != nil {
            
            let stop: String = UserDefaults.standard.object(forKey: "favourites") as! String
            let direction: String = "City"
            
            let timetable = dataManager.timetableParser(stopNumber: stop, direction: direction)
            var bus = ""
            var holdTime = "24:00"
            for (route, arrivalTime) in timetable! {
                if arrivalTime.string! > dataManager.getTime24Hour() && arrivalTime.string! < holdTime {
                    
                    print (arrivalTime)
                    bus = "Next bus arrives at \(arrivalTime) from \(stop) to \(direction) "
                    holdTime = arrivalTime.string!
                    
                }
                textLabel.text = bus
                
            }
        } else {
            textLabel.text = "You have not favourited any stops yet"
        }
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
