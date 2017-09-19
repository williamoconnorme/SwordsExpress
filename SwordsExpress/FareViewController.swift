//
//  SecondViewController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 30/07/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit

let getFares = Fares()

class FareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var segPaymentType: UISegmentedControl!
    
    
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
        
        let segmentSelection = (segPaymentType.selectedSegmentIndex, segControl.selectedSegmentIndex)

        switch segmentSelection {
        case (0, 0):
            return getFares.cashType.count
        case (0, 1):
            return getFares.cashType.count
        case (0, 2):
            return getFares.cashType.count
        case (1, 0):
            return getFares.leapType.count
        case (1, 1):
            return getFares.leapType.count
        case (1 ,2):
            return getFares.leapType.count
        case (2, 0):
            return getFares.taxsaverType.count
        case (2, 1):
            return getFares.taxsaverType.count
        case (2, 2):
            return getFares.taxsaverType.count
            
        default:
            print ("numberOfRowsInSection returned only default row")
            return 1
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FareTableViewCell
        
        let segmentSelection = (segPaymentType.selectedSegmentIndex, segControl.selectedSegmentIndex)
        
        switch segmentSelection {
        case (0, 0):
            cell.typeLabel.text = getFares.cashType[indexPath.row]
            cell.fareLabel.text = getFares.cashAdult[indexPath.row]
            segControl.isEnabled = true
        case (0, 1):
            cell.typeLabel.text = getFares.cashType[indexPath.row]
            cell.fareLabel.text = getFares.leapAdult[indexPath.row]
            segControl.isEnabled = true
        case (0, 2):
            cell.typeLabel.text = getFares.cashType[indexPath.row]
            cell.fareLabel.text = getFares.cashChild[indexPath.row]
            segControl.isEnabled = true
        case (1, 0):
            cell.typeLabel.text = getFares.leapType[indexPath.row]
            cell.fareLabel.text = getFares.leapAdult[indexPath.row]
            segControl.isEnabled = true
        case (1, 1):
            cell.typeLabel.text = getFares.leapType[indexPath.row]
            cell.fareLabel.text = getFares.leapStudent[indexPath.row]
            segControl.isEnabled = true
        case (1, 2):
            cell.typeLabel.text = getFares.leapType[indexPath.row]
            cell.fareLabel.text = getFares.leapChild[indexPath.row]
            segControl.isEnabled = true
        case (2, 0):
            cell.typeLabel.text = getFares.taxsaverType[indexPath.row]
            cell.fareLabel.text = getFares.taxsaver[indexPath.row]
            segControl.isEnabled = false
        case (2, 1):
            cell.typeLabel.text = getFares.taxsaverType[indexPath.row]
            cell.fareLabel.text = getFares.taxsaver[indexPath.row]
            segControl.isEnabled = false
        case (2, 2):
            cell.typeLabel.text = getFares.taxsaverType[indexPath.row]
            cell.fareLabel.text = getFares.taxsaver[indexPath.row]
            segControl.isEnabled = false
        default:
            print ("Default switch statement in cellForRowAt used")
        }
        return cell
    }
    
    
}

