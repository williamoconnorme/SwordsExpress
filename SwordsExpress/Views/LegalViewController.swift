//
//  LegalViewController.swift
//  SwordsExpress
//
//  Created by William O'Connor on 20/09/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit

class LegalViewController: UIViewController {
    
    var page: Int = Int()
    
    @IBAction func dissmissButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch page {
        case 0:
            titleLabel.text = "Privacy Policy"
            bodyLabel.text = "This app does not collect personal information. Your location information is used to improve the accuracy of our journey routing service."
        case 1:
            titleLabel.text = "Terms and Conditions"
            bodyLabel.text = "We'll keep this short -- This app can not be used for Commercial purposes."
        case 2:
            titleLabel.text = "Licenses"
            bodyLabel.text = "• Whisper by hyperoslo\n• SwiftyJSON by SwiftyJSON\n• RevealingSplashView by PiXeL16"
        default:
            titleLabel.text = "Error"
            bodyLabel.text = "Unable to determine which page to lookup"
            print ("Page number is \(page)")
        }
        
        titleLabel.sizeToFit()
        bodyLabel.sizeToFit()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
