//
//  StopListTableViewCell.swift
//  SwordsExpress
//
//  Created by William O'Connor on 19/08/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit

class StopListTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        timeLabel.text = "Time Label"
        
        
        stopLabel.text = "Stop Label"
        
        routeLabel.text = "Route Label"
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
