//
//  PropertyViewedTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 8/8/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class PropertyViewedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblNiceDate: UILabel!
    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var propertyRating: UIImageView!
    @IBOutlet weak var agentRating: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
