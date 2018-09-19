//
//  InformationTableViewController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 16/08/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit
import StoreKit
import Whisper

class InformationTableViewController: UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    var tableIndex = 0
    var tableSection = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for review
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
        
        // Get and display app version and build number
        let appInfo = Bundle.main.infoDictionary! as Dictionary<String,AnyObject>
        let shortVersionString = appInfo["CFBundleShortVersionString"] as! String
        let bundleVersion      = appInfo["CFBundleVersion"] as! String
        versionLabel.text = "Version: \(shortVersionString) (\(bundleVersion))"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openOnTwitter() {
        let screenName =  "SwordsExpress"
        let appURL = URL(string: "twitter://user?screen_name=\(screenName)")!
        let webURL = URL(string: "https://twitter.com/\(screenName)")!
        
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL, options:  convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:  nil)
        } else {
            application.open(webURL, options:  convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler:  nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableIndex = indexPath.row
        tableSection = indexPath.section
        
        switch tableSection {
        case 0:
            switch tableIndex {
            case 0:
                print ("Timestables")
            case 1:
                print ("Fares")
            default:
                print ("Didnt work")
            }
        case 1:
            switch tableIndex {
            case 0:
                let email = "feedback@swordsexpress.ie"
                if let url = URL(string: "mailto:\(email)") {
                    UIApplication.shared.open(url)
                }
            case 1:
                print ("Timetables")
                openOnTwitter()
            case 2:
                print ("Call US")
                if let call: String = "+35315292277",
                    let url = URL(string: "tel://\(call)"),
                    UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                }
            default:
                print ("Didnt work")
            }
        case 2:
            print ("Section 2 selected")
            
        default:
            print ("No index selected")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "informationToLegal" {
            
            let navController = segue.destination as! UINavigationController
            let vc = navController.topViewController as! LegalViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let selectedCell = indexPath?.row
            
            vc.page = selectedCell!
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
