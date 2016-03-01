//
//  SeeitNowTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 2/29/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class SeeitNowTableViewCell: UITableViewCell {

    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblShowingRate: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var btnViewDetails: UIButton!
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
