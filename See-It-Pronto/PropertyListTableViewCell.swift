//
//  PropertyListTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 4/8/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class PropertyListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnViewDetails: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
