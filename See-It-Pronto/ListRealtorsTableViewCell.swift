//
//  ListRealtorsTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 2/17/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class ListRealtorsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStaring: UILabel!
    @IBOutlet weak var lblTravelRange: UILabel!
    @IBOutlet weak var lblShowingRate: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var lblBrokerage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func btnViewDetails(sender: AnyObject) {
        
    }

}
