//
//  AppointmentsTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/14/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class AppointmentsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var niceDate: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
  
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
