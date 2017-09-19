//
//  TodayViewController.swift
//  SE Widget
//
//  Created by William O'Connor on 18/08/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let dataManager = DataManager()
    var favData: Array = [String]()
    var favObj = [Schedule]()
    let favArray: Array = UserDefaults(suiteName: "group.swordsexpress.test")!.array(forKey: "fav")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        initializeTableData()
        
        
        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        self.preferredContentSize.height = 200
        
        
    }
    
    func initializeTableData() {
        
        if (UserDefaults(suiteName: "group.swordsexpress.test")!.array(forKey: "fav") != nil) {
            
            
            for item in favArray {
                
                let stop: String = item as! String
                let direction: String = "city"
                
                let data = dataManager.extractNextArrivalTime(stopNumber: stop , direction: direction)

            }
        } else {
            //textLabel.text = "You have not favourited any stops yet"
        }
        
        
        
        self.tableView.reloadData()
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: maxSize.width, height: 500)
        }
        else if activeDisplayMode == .compact {
            preferredContentSize = maxSize
        }
    }
    
    func tableview(_ tableView: UITableView, numberOfSections section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (favArray.count)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        
        
        
        //cell?.textLabel?.text = data?[indexPath.row].stop
        return cell!
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
