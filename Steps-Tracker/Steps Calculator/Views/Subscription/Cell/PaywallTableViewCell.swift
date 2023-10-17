//
//  PaywallTableViewCell.swift
//  Steps Calculator
//
//  Created by Shahryar Khan on 22/06/2021.
//  Copyright © 2021 HxB. All rights reserved.
//

import UIKit

class PaywallTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
