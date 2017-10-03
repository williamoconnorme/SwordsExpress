//
//  TimetableViewController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 19/09/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit

class TimetableStopsViewController: UITableViewController {
    
    var direction: Int = Int()
    
    let toSwords = [
        "Eden Quay",
        "IFSC",
        "Custom House Quay",
        "Custom House Quay",
        "North Wall Quay",
        "Point Depot",
        "Holywell Distributor Road",
        "Airside Central",
        "Boroimhe Maples",
        "Boroimhe Laurels",
        "Ballintrane",
        "Highfields",
        "Dublin Street",
        "Malahide Roundabout",
        "Seatown Road",
        "West Seatown",
        "Saint Colmcille's GFC",
        "Jugback Lane",
        "Applewood Estate",
        "Laurelton",
        "Cianlea",
        "Ardcian",
        "Lios Cian",
        "Valley View",
        "Saint Cronan's South",
        "Swords Manor",
        "Merrion Square"
    ]
    
    let toCity = [
        "Abbeyvale",
        "Swords Manor",
        "Valley View",
        "The Gallops",
        "Lios Cian",
        "Cianlea",
        "Laurelton",
        "Applewood Estate",
        "Jugback Lane",
        "Saint Colmcille's GFC",
        "West Seatown",
        "Seatown Road",
        "Swords Bypass",
        "Malahide Roundabout",
        "Pavilions Shopping Centre",
        "Dublin Road (opp Penneys)",
        "Highfields",
        "Ballintrane",
        "Boroimhe Laurels",
        "Boroimhe Maples",
        "Airside Road",
        "Airside Central",
        "Holywell Distributor Road",
        "M1 Drinan",
        "East Wall Road",
        "Convention Centre",
        "Seán O'Casey Bridge",
        "Eden Quay"
    ]
    
    var selection = [String]()
    var dir: String = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch direction {
        case 0:
            selection = toCity
            dir = "city"
        case 1:
            selection = toSwords
            dir = "swords"
        default:
            selection = toCity
            dir = "city"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return selection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = selection[indexPath.row]
        
        // Configure the cell...
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "timetableToStopView" ,
            let nextView = segue.destination as? StopListViewController ,
            let indexPath = self.tableView.indexPathForSelectedRow {
            let selectedCell = selection[indexPath.row]
            let direction = dir
            
            nextView.PassedStopData = [selectedCell, direction]
        }
    }
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
