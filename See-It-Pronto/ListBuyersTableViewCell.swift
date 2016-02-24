//
//  ListBuyersTableViewCell.swift
//  See-It-Pronto
//
//  Created by user114136 on 2/22/16.
//  Copyright © 2016 user114136. All rights reserved.
//

import UIKit

class ListBuyersTableViewCell: UITableViewCell {

    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    @IBAction func btnViewDetails(sender: AnyObject) {
        
    }
}
