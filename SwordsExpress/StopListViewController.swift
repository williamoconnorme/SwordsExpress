//
//  StopListViewController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 19/08/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit
import WatchConnectivity
import Whisper
import Foundation

class StopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let dataManager = DataManager()
    var data = [Schedule]()
    var PassedStopData: Array = [String]()
    var favourites = [Stop]()
    var favouritesData = [Data]()
    
    var favouriteDict: [[String: Any]] = [] // array for testing dictionary
    
    @IBOutlet weak var favouriteIcon: UIBarButtonItem!
    @IBAction func addRemoveFavourite(_ sender: Any) {
        
        let stop: Stop = Stop(name: PassedStopData[0], direction: PassedStopData[1])
        let stopData = NSKeyedArchiver.archivedData(withRootObject: stop)
        
        
        if (UserDefaults.standard.array(forKey: "favourites") != nil)
        {
            favouriteIcon.image = #imageLiteral(resourceName: "plus-sign-circle")
            
            
            
            let murmur = Murmur(title: "Removed \(PassedStopData[0]) from your favourites")
            Whisper.show(whistle: murmur, action: .show(3))
            
        } else {
            favouriteIcon.image = #imageLiteral(resourceName: "minus-sign-circle")
            
            
            
            let murmur = Murmur(title: "Added \(PassedStopData[0]) to your favourites")
            Whisper.show(whistle: murmur, action: .show(3))
            
        }
    }
    @IBAction func dissmissButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favouriteDict.append(["name": PassedStopData[0], "direction": PassedStopData[1]])
        print (favouriteDict)
        if (UserDefaults.standard.array(forKey: "favourites") != nil) {
            favouriteDict = UserDefaults.standard.array(forKey: "favourites") as! [[String : Any]]
            dump (favouriteDict)
            print ("Userdefaults array is NOT nil in viewdidload")
        } else {
            print ("Userdefaults array is nil in viewdidload")
        }
        
        
        
        
        
        
        Whisper.ColorList.Whistle.background = UIColor(displayP3Red:0.00, green:0.67, blue:0.31, alpha:1.0)
        Whisper.ColorList.Whistle.title = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        
        
        self.navigationController?.navigationBar.isTranslucent = false
        UIApplication.shared.statusBarStyle = .lightContent
        initializeTableData()
        
        
    }
    
    func initializeTableData() {
        data = dataManager.getFullTimetable(stopNumber: PassedStopData[0], direction: PassedStopData[1])!
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
