//
//  SecondViewController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 30/07/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBAction func segButton(_ sender: Any) {
        tableView.reloadData()
    }
    
    let leapFareAdult =
        ["Single Peak - €4.20",
         "Single Off-Peak - €3.20",
         "Ten Journey - €37",
         "Within Swords - €1.40",
         "Night Link - €6.00",
         "Weekend - €3.50"]
    
    let leapStudentFare =
        ["Single Peak - €3.20",
         "Single Off-Peak - €2.20",
         "Ten Journey - €27",
         "Within Swords - €1.40",
         "Night Link - €6.00",
         "Weekend - €2.50"]
    
    let leapChildFare =
        ["Single Peak - €2.20",
         "Single Off-Peak - €2.20",
         "Within Swords - €1.40",
         "Night Link - €6.00",
         "Weekend - €2.50"]
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if segControl.selectedSegmentIndex == 0 {
            return leapFareAdult.count
        } else if segControl.selectedSegmentIndex == 1 {
            return leapStudentFare.count
        } else if segControl.selectedSegmentIndex == 2 {
            return leapChildFare.count
        }
        return 1
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        if segControl.selectedSegmentIndex == 0 {
            cell.textLabel?.text = leapFareAdult[indexPath.row]
        } else if segControl.selectedSegmentIndex == 1 {
            cell.textLabel?.text = leapStudentFare[indexPath.row]
        } else if segControl.selectedSegmentIndex == 2 {
            cell.textLabel?.text = leapChildFare[indexPath.row]
        }
        return cell
    }
    
    
}

