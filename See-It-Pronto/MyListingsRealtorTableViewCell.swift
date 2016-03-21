//
//  MyListingsTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/14/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class MyListingsRealtorTableViewCell: UITableViewCell {

  
    @IBOutlet weak var btnBeacon: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var PropertyImage: UIImageView!
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var swBeacon: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
