//
//  MyListingsBuyerTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/21/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class SeeItLaterBuyerTableViewCell: UITableViewCell {

    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblNiceDate: UILabel!
    
    @IBAction func btnViewDetails(sender: AnyObject) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
