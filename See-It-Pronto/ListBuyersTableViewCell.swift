//
//  ListBuyersTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 2/22/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class ListBuyersTableViewCell: UITableViewCell {

    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    @IBAction func btnViewDetails(_ sender: AnyObject) {
        
    }
}
