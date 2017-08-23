//
//  StopListViewController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 19/08/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit

class StopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let dataManager = DataManager()
    var data = [Schedule]()
    var PassedStopData: Array = [String]()
    
    @IBAction func addRemoveFavourite(_ sender: Any) {
        
        if let added = UserDefaults.standard.object(forKey: "favourite") as? Array<String>
        {
            
            print ("removed favourite")
            //UserDefaults.standard.remove("Swords Manor", forKey: "favourite")
        } else {
            print ("added favourite")
            UserDefaults.standard.set("Swords Manor", forKey: "favourite")
        }
        
        
    }
    @IBAction func dissmissButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        UIApplication.shared.statusBarStyle = .lightContent
        initializeTableData()
        
    }
    
    func initializeTableData() {
        data = dataManager.getFullTimetable(stopNumber: PassedStopData[0], direction: PassedStopData[1])!
        //data = data.
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (data.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StopListTableViewCell
        
        cell.stopLabel.text = data[indexPath.row].stop
        cell.routeLabel.text = data[indexPath.row].route
        cell.timeLabel.text = data[indexPath.row].time
        return cell
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
