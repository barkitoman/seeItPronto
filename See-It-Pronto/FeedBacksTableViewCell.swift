//
//  FeedBacksTableViewCell.swift
//  See-It-Pronto
//
//  Created by Deyson on 3/28/16.
//  Copyright © 2016 Deyson. All rights reserved.
//

import UIKit

class FeedBacksTableViewCell: UITableViewCell {

    @IBOutlet weak var rating: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imageFeedback: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
