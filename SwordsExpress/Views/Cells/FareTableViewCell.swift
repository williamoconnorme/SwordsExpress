//
//  FareTableViewCell.swift
//  SwordsExpress
//
//  Created by William O'Connor on 18/09/2017.
//  Copyright © 2017 William O'Connor. All rights reserved.
//

import UIKit

class FareTableViewCell: UITableViewCell {

    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var fareLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
