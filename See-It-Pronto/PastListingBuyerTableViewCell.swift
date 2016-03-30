//
//  PastListingBuyerTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/30/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class PastListingBuyerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblNiceDate: UILabel!
    @IBOutlet weak var propertyImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
