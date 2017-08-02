//
//  SecondViewController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 30/07/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit

let getFares = Fares()

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBAction func segButton(_ sender: Any) {
        tableView.reloadData()
    }
    

    
    
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
            return getFares.leapFareAdult.count
        } else if segControl.selectedSegmentIndex == 1 {
            return getFares.leapStudentFare.count
        } else if segControl.selectedSegmentIndex == 2 {
            return getFares.leapChildFare.count
        }
        return 1
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        if segControl.selectedSegmentIndex == 0 {
            cell.textLabel?.text = getFares.leapFareAdult[indexPath.row]
        } else if segControl.selectedSegmentIndex == 1 {
            cell.textLabel?.text = getFares.leapStudentFare[indexPath.row]
        } else if segControl.selectedSegmentIndex == 2 {
            cell.textLabel?.text = getFares.leapChildFare[indexPath.row]
        }
        return cell
    }
    
    
}

