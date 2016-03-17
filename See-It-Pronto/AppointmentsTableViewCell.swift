//
//  AppointmentsTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/14/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class AppointmentsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var niceDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
  
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
