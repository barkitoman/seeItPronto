//
//  MyListingsBuyerTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/21/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class MyListingsBuyerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imageProperty: UIImageView!
    
    @IBOutlet weak var lblDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
